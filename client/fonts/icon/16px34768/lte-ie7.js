/* Load this script using conditional IE comments if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'16px\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-handle' : '&#xe002;',
			'icon-ring' : '&#xe003;',
			'icon-cube' : '&#xe000;',
			'icon-triangle1' : '&#xe004;',
			'icon-sine' : '&#xe005;',
			'icon-triangle2' : '&#xe006;',
			'icon-square' : '&#xe007;',
			'icon-saw' : '&#xe008;',
			'icon-clear' : '&#xe00a;',
			'icon-save' : '&#xe00b;',
			'icon-hold' : '&#xe00c;',
			'icon-sequencers' : '&#xe00d;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, html, c, el;
	for (i = 0; i < els.length; i += 1) {
		el = els[i];
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};