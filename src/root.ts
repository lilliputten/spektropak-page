/** @module Scripts root module
 *  @since 2024.10.10, 15:26
 *  @changed 2024.10.13, 19:40
 */

// NOTE: Templates are including only for dev-mode update
import './include-template.html';

import './project-info.scss';
import './variables/variables-expose.scss';

import './misc-styles';

import { initOptionsSection } from './OptionsSection';

// Print app info...
const appVersion = process.env.APP_VERSION;
const isDebug = process.env.DEBUG;
const isDev = process.env.DEV;
// eslint-disable-next-line no-console
const consoleMethod = isDebug || isDev ? console.warn : console.log;
consoleMethod.call(console, appVersion);

function initPage() {
  // console.log('[root:initPage]');
  // Start subcomponents...
  initOptionsSection();
}

window.addEventListener('load', initPage);
