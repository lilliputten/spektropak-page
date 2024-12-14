function closeOthers(thisItemNode: HTMLElement) {
  const parentNode = thisItemNode.parentNode as HTMLElement;
  const nodes = parentNode.querySelectorAll(':scope > li');
  nodes.forEach((node) => {
    if (node !== thisItemNode) {
      const button = node.querySelector(':scope > button[aria-expanded="true"]') as HTMLElement;
      const collapse = node.querySelector(':scope > .collapse.show') as HTMLElement;
      if (button) {
        button.setAttribute('aria-expanded', 'false');
      }
      if (collapse) {
        collapse.classList.toggle('show', false);
      }
    }
  });
}

function onClickToggle(ev: MouseEvent) {
  const node = ev.currentTarget as HTMLElement;
  const parentNode = node.parentNode as HTMLElement;
  const parentId = parentNode.id;
  const dataset = node.dataset;
  const { target: targetQuery } = dataset;
  const targetNode = parentNode.querySelector(targetQuery);
  const expanded = node.getAttribute('aria-expanded');
  const isExpanded = expanded === 'true';
  const setIsExpaned = !isExpanded;
  /* console.log('[OptionsSection:onClickToggle]', {
   *   parentId,
   *   ev,
   *   node,
   *   expanded,
   *   isExpanded,
   *   dataset,
   *   parentNode,
   *   targetNode,
   * });
   */
  if (!targetNode) {
    const error = new Error('Not found target node for ' + parentId);
    // eslint-disable-next-line no-console
    console.error('[OptionsSection:onClickToggle]', error.message, {
      parentId,
      parent,
      node,
      error,
    });
    debugger; // eslint-disable-line no-debugger
    throw error;
  }
  closeOthers(parentNode);
  node.setAttribute('aria-expanded', setIsExpaned ? 'true' : 'false');
  targetNode.classList.toggle('show', setIsExpaned);
}

export function initOptionsSection() {
  const sectiontNode = document.querySelector('.OptionsSection');
  const buttons = sectiontNode.querySelectorAll('ul.Items > li > button[data-toggle="collapse"]');
  buttons.forEach((item) => {
    item.addEventListener('click', onClickToggle);
  });
}
