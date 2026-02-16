import { getPermalink, getBlogPermalink, getAsset } from './utils/permalinks';

export const headerData = {
  links: [
    { text: '首页', href: getPermalink('/') },
    {
      text: '分类',
      links: [
        { text: 'AI', href: getPermalink('ai', 'category') },
        { text: '技术', href: getPermalink('技术', 'category') },
        { text: '游戏', href: getPermalink('游戏', 'category') },
      ],
    },
    { text: '文章', href: getBlogPermalink() },
    { text: '关于', href: getPermalink('/about') },
  ],
  actions: [],
};

export const footerData = {
  links: [
    {
      title: '栏目',
      links: [
        { text: 'AI', href: getPermalink('ai', 'category') },
        { text: '技术', href: getPermalink('技术', 'category') },
        { text: '游戏', href: getPermalink('游戏', 'category') },
      ],
    },
    {
      title: '页面',
      links: [
        { text: '首页', href: getPermalink('/') },
        { text: '文章', href: getBlogPermalink() },
        { text: '关于', href: getPermalink('/about') },
      ],
    },
  ],
  secondaryLinks: [
    { text: 'Terms', href: getPermalink('/terms') },
    { text: 'Privacy Policy', href: getPermalink('/privacy') },
  ],
  socialLinks: [
    { ariaLabel: 'RSS', icon: 'tabler:rss', href: getAsset('/rss.xml') },
    { ariaLabel: 'Github', icon: 'tabler:brand-github', href: 'https://github.com/ToxicantX/eyes-night' },
  ],
  footNote: `© ${new Date().getFullYear()} 小一一的博客 · 记录真实项目，持续迭代成长。`,
};
