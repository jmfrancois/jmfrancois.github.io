import tailcss from 'tailcss';
import styles from './link.module.css';

export const a1 = tailcss('text-xxl', 'font-bold', 'text-default', styles.link);
export const a2 = tailcss('text-xl', 'font-semibold', 'text-default', styles.link);
export const side = tailcss('flex', 'items-center', 'gap-xs', 'px-s', 'py-s', 'rounded-l', 'font-m', styles.side);