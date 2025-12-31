---
title:  "Web Components and React: A Pragmatic POC in the Enterprise"
categories: ["en"]
tags: ["Talend", "JavaScript", "Web Components", "React", "Architecture"]
date: 2020-03-24
---

Web Components are often presented as the future of frontend development. At Talend, we wondered: could we use Web Components alongside React? Could they help us build a more modular, framework-agnostic architecture? I conducted a POC to find out. What I discovered challenged some common assumptions about Web Components.

## The Dream: Framework-Agnostic Components

The promise of Web Components is seductive:

- **Framework-agnostic** : Write once, use anywhere (React, Vue, Angular, vanilla JS...)
- **Encapsulation** : Shadow DOM ensures styles don't leak
- **Reusability** : True components that work across teams and projects
- **Future-proof** : Built on web standards, not tied to any framework

At Talend, we have multiple teams, mainly using react, and lots of duplicated component logic. Web Components hipe goes up and down.

So I've built a POC: a simple button component as a Web Component, wrapped for React, and compared it with a native React component.

## The POC: Building a Simple Button

### Web Component Implementation

First, we created a pure Web Component button:

```javascript
class ShadowButton extends HTMLElement {
  constructor() {
    super();
  }
  
  connectedCallback() {
    if (!this.shadowRoot) {
      this.attachShadow({ mode: "open" });
      const button = document.createElement('button');
      button.textContent = this.getAttribute('label') || 'Click me';
      button.addEventListener('click', () => {
        this.dispatchEvent(new CustomEvent('click', { detail: 'button clicked' }));
      });
      
      const style = document.createElement('style');
      style.textContent = `
        button {
          background: #007bff;
          color: white;
          padding: 10px 20px;
          border: none;
          border-radius: 4px;
          cursor: pointer;
        }
        button:hover {
          background: #0056b3;
        }
      `;
      
      this.shadowRoot.appendChild(style);
      this.shadowRoot.appendChild(button);
    }
  }
}

customElements.define('my-button', ShadowButton);
```

### Using Web Components in React

Then we had to figure out how to use this Web Component in React. The straightforward approach doesn't work due to React's event system and how it handles custom elements:

```javascript
// ❌ This doesn't work well
export function MyButton({ label, onClick }) {
  const ref = useRef(null);
  
  useEffect(() => {
    if (ref.current) {
      ref.current.addEventListener('click', onClick);
    }
  }, [onClick]);
  
  return <my-button ref={ref} label={label} />;
}
```

The issue is that React treats Web Components like regular HTML elements and doesn't properly handle custom events or properties.

### The React Wrapper Solution

We created a generic wrapper component to bridge the gap:

```javascript
import React from 'react';

export default function WebComponent({ component, ...props }) {
  const [myEl, setState] = React.useState(document.createElement(component));
  const el = React.useRef(null);
  
  React.useEffect(() => {
    if (myEl.tagName.toLowerCase() !== component.toLowerCase()) {
      setState(document.createElement(component));
    } else {
      Object.keys(props).forEach(key => {
        if (typeof props[key] === 'string') {
          myEl.setAttribute(key, props[key]);
        } else {
          myEl[key] = props[key];
        }
      });
    }
    
    if (el.current) {
      el.current.appendChild(myEl);
    }
  }, [component, props]);
  
  return <div ref={(ref) => { el = ref; }}></div>;
}

// Usage in React
export function MyButtonWrapper(props) {
  return <WebComponent component="my-button" {...props} />;
}
```

This works, but it's clunky. You're essentially bypassing React's virtual DOM and directly manipulating the DOM.

### The Shadow DOM + React Challenge

We also explored rendering React **inside** a Web Component's Shadow DOM. This required a workaround because React has issues with synthetic events in Shadow DOM:

```javascript
/**
 * IMPORTANT NOTE:
 * Because React uses synthetic events, we have to patch the shadowDOM.
 * The following patch must be applied just after attachShadow
 * and you must not use document.createElement. Use shadowRoot.createElement instead.
 * Source: https://github.com/facebook/react/issues/9242
 */
function changeOwnerDocumentToShadowRoot(element, shadowRoot) {
  Object.defineProperty(element, 'ownerDocument', { value: shadowRoot });
}

function augmentAppendChildWithOwnerDocument(elem, shadowRoot) {
  const origAppChild = elem.appendChild;
  const propDesc = Object.getOwnPropertyDescriptor(elem, 'appendChild');
  
  if (!propDesc || propDesc.writable) {
    Object.defineProperty(elem, 'appendChild', {
      value: function (child) {
        changeOwnerDocumentToShadowRoot(child, shadowRoot);
        origAppChild?.call(elem, child);
      }
    });
  }
}

function augmentCreateElementWithOwnerDocument(shadowRoot, createFnName) {
  const originalCreateFn = document[createFnName];
  shadowRoot[createFnName] = (...args) => {
    const element = originalCreateFn.call(document, ...args);
    changeOwnerDocumentToShadowRoot(element, shadowRoot);
    augmentAppendChildWithOwnerDocument(element, shadowRoot);
    return element;
  };
}

export function patchShadowForReact(shadowRoot) {
  augmentCreateElementWithOwnerDocument(shadowRoot, 'createElement');
  augmentCreateElementWithOwnerDocument(shadowRoot, 'createElementNS');
  augmentCreateElementWithOwnerDocument(shadowRoot, 'createTextNode');
}

// Usage in a Web Component
class ReactButton extends HTMLElement {
  connectedCallback() {
    if (!this.shadowRoot) {
      this.attachShadow({ mode: "open" });
      patchShadowForReact(this.shadowRoot);
      
      const root = this.shadowRoot.createElement('div');
      this.shadowRoot.appendChild(root);
      
      ReactDOM.render(<MyReactButton {...this.props} />, root);
    }
  }
}
```

We actually had to **monkey-patch React** to make it work with Shadow DOM. Let that sink in. That's not a good sign.

## What We Learned

### 1. Isolation is a Double-Edged Sword

**The Problem:**
Shadow DOM isolates styles, which is great for preventing CSS conflicts. But it also makes sharing styles **really complicated**.

Let's say you want a consistent design system where all buttons have the same font, spacing rules, theme colors. In React, you'd share CSS or CSS-in-JS libraries easily.

With Web Components and Shadow DOM:

```javascript
// ❌ Your global styles don't reach the Shadow DOM
const globalStyles = `
  button {
    font-family: Segoe UI, sans-serif;
    color: var(--primary-color);
  }
`;

// ✅ You have to pass styles through attributes/properties or use CSS variables
customElements.define('my-button', class extends HTMLElement {
  connectedCallback() {
    const style = document.createElement('style');
    // You have to manually include/inherit styles
    style.textContent = `
      :host {
        --primary-color: #007bff;
      }
      button {
        color: var(--primary-color);
      }
    `;
    this.shadowRoot.appendChild(style);
  }
});
```

CSS variables **are** the solution, but they add complexity. You're essentially passing configuration through a CSS variable tunnel. At scale, this becomes painful:

```html
<my-button 
  style="
    --primary-color: #007bff;
    --primary-hover: #0056b3;
    --font-family: Segoe UI;
    --padding: 10px 20px;
    --border-radius: 4px;
  "
></my-button>
```

This defeats one of the main reasons we love React: **declarative props**.

### 2. The Implicit API Problem

Here's the real insight: React succeeded because it made a fundamental shift in how we think about UIs:

**Before React :**
```javascript
// Imperative - how to update the DOM
button.textContent = label;
button.style.color = color;
button.className = active ? 'active' : 'inactive';
button.onclick = handler;
```

**With React :**
```javascript
// Declarative - describe the desired state
<Button label={label} color={color} active={active} onClick={handler} />
```

React made the mental model **explicit and simple**: state → render → UI.

Web Components have the **implicit API** problem. You have to know:
- Which attributes exist? Which are properties?
- What events does it dispatch?
- What methods are available?
- When does the component re-render?

```javascript
// With a Web Component, is this right?
<my-button 
  label="Click me"          // attribute or property?
  disabled={true}            // attribute or property?
  onChange={handler}         // event listener or callback prop?
  ref={ref}                  // how do I call methods?
/>
```

Compare with React:

```javascript
<Button 
  label="Click me"           // prop (clear)
  disabled={true}            // prop (clear)
  onChange={handler}         // callback prop (clear)
  ref={ref}                  // ref (clear)
/>
```

The React API is **explicit and predictable**. Web Components require you to learn each component's specific API.

### 3. React Has Bugs with Properties vs Attributes

Here's where I really got frustrated: **React doesn't differentiate between properties and attributes**.

In HTML/DOM:

```javascript
// Attributes are strings in the HTML
<input type="text" disabled />
<button data-value="test"></button>

// Properties are JavaScript object properties
const input = document.querySelector('input');
input.disabled = true;              // property
input.setAttribute('disabled', ''); // attribute

input.value = 'hello';              // property
input.getAttribute('value');        // attribute (might be different!)
```

React treats everything as an attribute:

```javascript
// React does this:
element.setAttribute('disabled', 'true');  // ❌ Wrong! Becomes the string "true"

// It should do this for properties:
element.disabled = true;  // ✅ Correct
```

This causes real bugs when using Web Components:

```javascript
<my-checkbox checked={true} />
// React sets: element.setAttribute('checked', 'true')
// But the component expects: element.checked = true

// The component might not work correctly!
```

React's solution? They're slowly improving this, but it's been an issue for years. There's a whole GitHub issue about it (#9242).

## The Verdict

After the POC, here's our conclusion:

### When Web Components Make Sense
- **Third-party integrations** : Embedding non-React widgets in your app
- **Framework transitions** : If you're migrating from one framework to another
- **True cross-framework sharing** : If you genuinely need the same component in React, Vue, AND Angular
- **Progressive enhancement** : Building layers that don't require a full framework

### When They Don't
- **Enterprise React applications** : React's declarative model is superior for application development
- **Design systems** : React component libraries (like Material-UI, Chakra) are better
- **Shared libraries** : If everyone uses React, just use React components
- **Performance** : Web Components aren't faster; they require workarounds with React

## The Real Issue: We Keep Forgetting React Solved a Problem

React's success isn't just about virtual DOMs or performance. It's about **making UIs simple to reason about**.

Web Components try to be framework-agnostic, but at what cost? You lose:
- **Predictable APIs** : No standard way to handle props, events, lifecycle
- **Developer experience** : You're writing framework-specific wrappers constantly
- **Tooling support** : IDEs struggle with custom elements without a framework

We keep trying to reinvent the wheel. React (and Vue, Angular) are popular **because** they solved this.

## Our Decision at Talend

We abandoned the Web Component strategy for our main design system. Instead, we:

1. **Kept React** for our design system (it's what 95% of our teams use)
2. **Made it truly framework-agnostic** by externalizing components via UMD/CDN (different approach, more effective)
3. **Used Web Components strategically** for third-party integrations only

## Code References

The POC code is available in two gists:

1. **Patching React for Shadow DOM** : https://gist.github.com/jmfrancois/a728521a1cee561e5fb8370b2882a863
   - Shows the workaround needed for React to work with Shadow DOM
   
2. **React Wrapper for Web Components** : https://gist.github.com/jmfrancois/90fecb86695f38e0e234f3ac1ad050c7
   - A generic wrapper to use Web Components in React

Both are hacky. Both prove the point: mixing Web Components and React requires friction.

## Conclusion

Web Components are a powerful standard. But they're not a silver bullet for component reusability in enterprise applications.

The lesson? **Don't chase the shiny new standard just because it's a standard.** React solved real problems. Web Components solve different ones.

If you're building a React app, build React components. If you need true framework independence, that's a rare requirement that deserves a rare solution (like micro-frontends with separate frameworks).

And if you do go down the Web Component path in React, remember to apply that Shadow DOM patch and reconsider your life choices.

---

**References:**
- [Web Components MDN](https://developer.mozilla.org/en-US/docs/Web/Web_Components)
- [React and Shadow DOM Issue](https://github.com/facebook/react/issues/9242)
- [Web Components vs React](https://www.thinktecture.com/en/web-components/introduction/)
- [Custom Elements Spec](https://html.spec.whatwg.org/multipage/custom-elements.html)


