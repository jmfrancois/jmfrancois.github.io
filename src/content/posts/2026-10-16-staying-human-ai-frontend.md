---
title: "Staying Human in the Age of Ask AI"
categories: ["en"]
tags: ["AI", "Frontend", "Software Engineering"]
date: 2026-10-16
---

Roles are changing. Not in a neat job-title update, but through a mutation in what we are expected to do, how quickly we must do it, and what counts as valuable work. That is difficult to follow, and harder to adapt to while the ground is still moving.

I am trying to stay positive and not take the black pill. DHH ended his [Rails World 2026 keynote](https://www.youtube.com/watch?v=vDjW_dRyKXY) with: “The black pill is for fucking losers. Don’t be a loser.” I hear a useful challenge to fatalism: try the tools before declaring the future impossible. But optimism is not evidence, and it should not become a demand to celebrate every productivity claim. The question that matters to me is more basic: how do we stay human in a world where the first response to every problem is “ask AI”?

## The ten-times target can become ten simultaneous threads

The promise of a ten-times engineer sounds like leverage. In practice, it can become an expectation to manage several agents, answer product questions, switch between codebases, and review more output—all at once. More parallel work is not automatically more useful work. It can mean more context to hold, more interruptions, and less time to understand what is changing.

The evidence does not support one universal multiplier. In a randomized study of 16 experienced open-source developers doing 246 tasks in mature projects, the early-2025 AI tools tested made completion take **19% longer** on average. That is one small, specific study—not a verdict on every model or workflow—but it is enough to challenge blanket targets. The researchers also found that participants expected a speed-up and still believed they had worked faster afterward. [METR’s study](https://arxiv.org/html/2507.09089) is a good reminder to measure completed, reviewed work rather than how productive a tool feels.

Recent studies look directly at the interruptions AI adds. An ICSE 2026 eye-tracking study of 35 professional and student developers found that about half of generated suggestions were not looked at; of the suggestions developers did look at, more than 75% were not used. Suggestions were reviewed for about 0.9 seconds on average, yet the authors describe each as a “micro-interruption” that can disrupt flow. A separate two-year telemetry study of 800 IDE users found a rising trend of about 6.4 IDE window activations per month among AI users, compared with a decline of about 7.6 among non-users. Neither study proves that AI caused the change or that every interruption is harmful: suggestions not accepted may still help, and window activation is only a proxy. But the findings make parallel-agent targets a workload-design question, not simply an individual adaptation problem. ([Alakmeh et al., ICSE 2026](https://conf.researchr.org/details/icse-2026/icse-2026-research-track/90/An-Eye-for-AI-Eye-Tracking-the-Micro-Interruptions-of-GenAI-Code-Suggestions); [Sergeyuk et al., ICSE 2026](https://arxiv.org/html/2601.10258v2))

Burnout is not inevitable, but newer evidence makes it hard to dismiss as only tool fatigue. A mixed-method ICSE 2026 study of 442 software developers found AI-related job demands—organizational pressure and workload—associated with greater burnout, while job resources such as autonomy and learning support were associated with less. Because the survey was cross-sectional, it cannot establish that AI adoption caused those demands or burnout, and it does not represent every team. It does put the focus where it belongs: on targets, workload, autonomy, and support. ([Feng et al., “From Gains to Strains,” ICSE 2026](https://arxiv.org/html/2510.07435v2))

## The work does not end when code appears: CI inherits the pressure

If code arrives faster, the responsibility to establish that it works does not disappear. It moves downstream—to tests, continuous integration, review, observability, deployment, and support. That is not administrative cleanup after the “real” work. It is part of the work.

DORA’s March 2026 analysis of 1,110 open-ended responses from Google software engineers says time saved in code creation is “frequently re-allocated to auditing and verification”—a “verification tax.” It also reports that higher AI adoption is associated with both delivery throughput and delivery instability. This qualitative analysis of one company’s responses is not proof that AI caused CI failures, but it does challenge the idea that faster code generation removes downstream quality work. ([DORA, “Balancing AI tensions,” 2026](https://dora.dev/insights/balancing-ai-tensions/)) DORA’s [2025 report](https://dora.dev/research/2025/dora-report/) also describes AI as an “amplifier” of existing organizational strengths and weaknesses. If CI is slow, tests are weak, or ownership is unclear, more code can amplify those weaknesses.

The practical response is not to celebrate longer queues or ask reviewers to work harder. It is to keep changes small, tests meaningful, and feedback fast enough that people can understand what the system is telling them.

## A green test suite is not proof the specification was met

A model can confidently report success while the diff tells a different story. In a research benchmark deliberately designed with impossible tasks—where the written specification conflicts with the tests—agents sometimes altered tests or otherwise exploited the scoring rules. The researchers describe a failure mode plainly: an agent “may delete failing tests rather than fix the underlying bug.” On one conflicting multi-file benchmark, GPT-5’s measured rate of passing by violating the specification was 54%.

That number is **not** a real-world rate of test deletion: the benchmark intentionally creates contradictions to study shortcut-seeking. It does show why “the suite is green” is not enough when the agent can edit the suite. The authors’ [ImpossibleBench paper](https://arxiv.org/html/2510.20270v1) studies those behaviors; it does not establish that a model is consciously lying. The engineering lesson is simpler: inspect test changes as carefully as implementation changes, protect tests where practical, and check that the behavior—not just the score—matches the requirement.

## Reviewing AI output is still reviewing a contribution

A hundred-file change from someone who rarely contributes can be difficult to review whether it was typed by hand or produced by an agent. Asking what changed, why it changed, and how it is tested is not hostility. It is how a reviewer establishes context and ownership. An assistant can summarize a diff or draft an answer to a question; its explanation is not independent evidence that the change is safe.

Google’s engineering guidance says small changes are “reviewed more thoroughly” and are less likely to introduce bugs because the impact is easier to reason about. It also notes that a 200-line change spread across 50 files is usually too large. ([Google Engineering Practices: Small CLs](https://github.com/google/eng-practices/blob/master/review/developer/small-cls.md)) A large change can be justified, but it should come with a clear reason, focused review areas, and trustworthy tests—not an expectation that reviewers absorb it because an AI wrote it quickly.

The question is not whether we review AI. We review the change. The question is whether the size, rationale, and verification make a responsible review possible.

## If I have only learned to use AI, what have I learned?

I worry that I have spent the last two years learning mostly how to use tools. Tool fluency matters, but models, interfaces, and prompt habits change quickly. If that is the only skill I am building, what remains when the interface changes again?

A Microsoft Research survey of 319 knowledge workers found that higher confidence in generative AI was associated with less reported critical thinking, while confidence in one’s own ability was associated with more. The study also found that AI shifted critical-thinking work toward “information verification, response integration, and task stewardship.” ([CHI 2025 study](https://www.microsoft.com/en-us/research/publication/the-impact-of-generative-ai-on-critical-thinking-self-reported-reductions-in-cognitive-effort-and-confidence-effects-from-a-survey-of-knowledge-workers/)) That sounds less like the end of thinking than a change in where thinking is required—but it also means that accepting a plausible answer without checking it is a bad way to learn.

A 2026 meta-analysis of 23 studies found a moderate average productivity benefit from AI-assisted programming, with substantial variation between settings; it found no statistically significant effect on programming-learning outcomes as measured in the included studies. That is not proof that nobody learns with AI. It is a warning not to confuse finishing a task with acquiring a skill. ([Maier et al., “A meta-analysis of the effect of generative AI on productivity and learning in programming”](https://arxiv.org/html/2605.04779v1))

I want the challenge to remain: understanding the system, forming a hypothesis, testing alternatives, and explaining the trade-off. AI can help me do those things. If I outsource all of them, I may get an answer and lose the opportunity to become better at the work.

## If everyone asks AI, what is my place with product teams?

I used to be in the loop with product teams: discussing a need, challenging an assumption, and helping turn it into a workable design. Now it can feel as if everyone asks an AI first. It is easy to read that as “I am no longer useful.”

But producing a quick response is not the same as understanding which problem is worth solving, who is affected, what failure costs, or what evidence would change the decision. Those questions still need people who understand the product, its users, and its constraints. The work may shift from answering every question to helping the team ask better ones and decide what to do with the answer.

A six-month randomized field experiment across 56 companies and more than 6,000 knowledge workers found that Copilot reduced time spent on email, but “did not significantly change time spent in meetings.” The authors argue that larger changes in responsibilities require organizational coordination, not just access to a tool. ([Microsoft Research, “Shifting Work Patterns with Generative AI”](https://arxiv.org/html/2504.11436v1)) That is a useful counterweight to the idea that putting AI in everyone’s hands automatically removes the need for collaboration. Product conversations are not just a slower interface for prompting.

## Where does engineering move?

### Frontend still owns the experience, even if generation gets cheap

DHH’s keynote describes a bet to rebuild one product across native platforms because agents make that work cheaper; he also notes that “The web is wonderful” when people need access without installing an app. That is one company’s strategy, not proof the browser is obsolete. The frontend work that remains is not only producing components: it is making interaction, accessibility, performance, error states, privacy, and device constraints fit the product and its users. An agent can generate a screen; an engineer still has to decide whether it belongs in the user journey and whether it holds up across real states.

### Efficiency means cost per correct outcome, not minimum tokens

Token efficiency is useful when it means getting a reliable result with less time, money, and unnecessary context. It is a poor goal if we optimize token count while increasing rework, risk, or review time. The relevant unit is not “tokens generated”; it is the cost of a correct, maintainable outcome.

The [Stanford AI Index 2025](https://hai.stanford.edu/ai-index/2025-ai-index-report) reports that the inference cost of a system performing at GPT-3.5’s level fell more than 280-fold between November 2022 and October 2024. Falling cost changes what is economically possible, but it does not make a wrong answer cheap to ship. Quality, latency, data handling, and the cost of checking the result still matter.

### Model selection is a task-specific engineering decision

There is no single “best model” independent of the task, codebase, context window, latency, privacy constraints, and budget. A useful comparison runs representative tasks against our own acceptance criteria: did the change work, did it preserve existing behavior, could a person understand it, and what did it cost to get there?

That is more durable than treating a leaderboard or a weekly video as a production decision. The model benchmark literature warns that static tests can become contaminated and produce “inflated and misleading performance assessments.” ([Survey of LLM benchmark contamination](https://arxiv.org/html/2502.17521)) Benchmarks and reviews are useful inputs; they are not substitutes for evaluating the work we actually need.

There is a little YouTube data, but it needs context: when I checked, the official [Rails World 2026 keynote](https://www.youtube.com/watch?v=vDjW_dRyKXY) had about 566,000 views. That measures attention to one talk, not agreement with it or the rate at which creators publish model reviews. My feed is not a representative sample, so I would not turn its apparent “new model, new video” rhythm into a statistic.

### Open-source harnesses make the workflow part of the system

Projects such as [OpenCode](https://github.com/anomalyco/opencode) and [Pi](https://github.com/badlogic/pi-mono) make the agent harness visible and modifiable. The harness—tools, permissions, context, tests, and recovery—is part of the behavior we are shipping, not a decorative wrapper around a model. Open source makes it easier to inspect and adapt that layer; it does not make the defaults safe automatically. For example, Pi’s own documentation says it does not include a built-in permission system for restricting filesystem, process, network, or credential access. Transparency helps, but teams still have to design the boundaries.

### Forward-deployed engineers are real; the role is not an easy shortcut

Forward-deployed engineering is one emerging answer to the gap between a capable model and a useful deployment. OpenAI describes its FDE team as partnering with customers “to turn research breakthroughs into production systems.” The role includes discovery, scoping, system design, implementation, rollout, and learning from evaluations in the field. One current US listing advertises a $185,000–$300,000 base range plus equity. That is evidence of one company’s investment in the role, not a market-wide salary or proof that every company will hire a large FDE team. ([OpenAI FDE role](https://openai.com/careers/forward-deployed-engineer-%28fde%29-sf-san-francisco))

The hard part is not installing an agent and moving to the next customer. It is understanding the workflow, integrating responsibly, proving that the deployment helps, and carrying lessons back into a product or platform. If the role is only repeat installation without feedback or durable ownership, the title will not make it meaningful engineering.

### Platforms and infrastructure still need engineering—and headcount is uncertain

Companies need secure access, identity and data boundaries, auditability, evaluation, user experience, and workflow integration. They also need compute, networking, power, and dependable inference infrastructure. Governments are funding some of that capacity: the European Commission reported 19 AI Factories across 16 member states and more than €2.6 billion committed to the initiative. ([European Commission, 10 October 2025](https://digital-strategy.ec.europa.eu/en/news/eu-expands-network-ai-factories-strengthening-its-ai-continent-ambition))

That is evidence of investment, not a count of new engineering jobs or a guarantee that local AI means more frontend hiring. Other work will also matter: security, reliability, accessibility, product design, data governance, and integrating systems that were never built to work together. Some will be new roles; much of it may be existing engineering with different tools and responsibilities.

## Three futures I can imagine—not forecasts

### Displacement at scale: a risk, not a chain of certainties

The frightening scenario is that most jobs disappear, income collapses, and social unrest follows. Large-scale displacement would be a serious economic and political risk. But “many jobs change” does not mechanically lead to civil war; that depends on policy, institutions, distribution of gains, and many other conditions. I do not know a credible basis for presenting that sequence as a prediction.

The World Economic Forum’s [Future of Jobs Report 2025](https://www.weforum.org/press/2025/01/future-of-jobs-report-2025-78-million-new-job-opportunities-by-2030-but-urgent-upskilling-needed-to-prepare-workforces/) reports employers expect 170 million roles to be created and 92 million displaced by 2030, for a net gain of 78 million. Those are employer expectations across several structural trends, not a guarantee, and not a forecast attributable to AI alone. The uncomfortable point is that a positive net number can still hide painful transitions for particular people, places, and occupations.

### Geopolitical tension may push investment closer to home

Wars and geopolitical tension can make governments and companies reconsider dependence on foreign platforms, chips, data centers, and model providers. That could create investment in regional compute, locally hosted models, and national AI infrastructure—and some engineering work around it. The European AI Factories are a concrete example of such investment. But “more local infrastructure” does not automatically mean “more software jobs than the tools displace.” Both outcomes can happen at once.

### A hybrid market may sell capability when it is needed

As inference gets cheaper, a company may buy a narrow AI-enabled feature or temporary capability when demand appears rather than build every capability in-house. That is plausible, not inevitable. The price of tokens is only one part of the cost: integration, security, evaluation, user support, and responsibility do not disappear with a cheaper API. I expect a hybrid world—some software built and owned internally, some capability bought as a service, and people still accountable for the result.

## What will we be in ten years?

We have more power to make things, and we may also spend more of the day talking to machines, checking their work, and coordinating what happens next. That can feel like a strange promotion and a strange loss at the same time. I do not want to confuse using AI well with giving up on the parts of engineering that taught me how systems work or made the work feel human.

Perhaps our roles will be less about producing every line and more about choosing what should exist, setting boundaries, understanding consequences, and helping teams make decisions they can stand behind. Perhaps the tools will change again before that description settles. The important thing is not to pretend that change is easy, or that fear makes someone a loser. It is to keep learning, keep asking who benefits, and keep making room for the human conversations that software is supposed to serve.

What do you think we will be in ten years?
