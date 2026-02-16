// Place any global data in this file.
// You can import this data from anywhere in your site by using the `import` keyword.

export const SITE_TITLE = '小一一的博客';
export const SITE_DESCRIPTION = '记录 AI、编程与日常思考，分享可落地的项目实践。';

export const CATEGORIES = [
	{ key: 'ai', name: 'AI', emoji: '🤖', tags: ['AI', 'ai', 'AI点子', '自动化', 'Agent'] },
	{ key: 'tech', name: '技术', emoji: '💻', tags: ['技术', '编程', '开发', 'Astro', 'GitHub Pages', '教程', 'MDX'] },
	{ key: 'game', name: '游戏', emoji: '🎮', tags: ['游戏', 'Game'] },
] as const;

export type CategoryKey = (typeof CATEGORIES)[number]['key'];

export function classifyByTags(tags: string[]): CategoryKey[] {
	const hit = new Set<CategoryKey>();
	for (const c of CATEGORIES) {
		if (tags.some((t) => c.tags.includes(t))) hit.add(c.key);
	}
	if (hit.size === 0) hit.add('tech');
	return Array.from(hit);
}
