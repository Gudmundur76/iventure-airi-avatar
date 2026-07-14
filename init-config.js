(function() {
  // Pre-seed AIRI configuration for iventure.studio
  var NEXOS_API_KEY = 'nexos-team-071780a05f6522ccb86b3dc090ae3212dfc68e1e8d8c5a687cc4322377208a65c36ebba9a71f8e2a93ddf26b82608f1b7b8be1716f812ad53810ee4fb9e5d1fa';
  var NEXOS_BASE_URL = 'https://api.nexos.ai/v1';
  var DEFAULT_MODEL = 'grok-4-20';

  function setIfEmpty(key, value) {
    if (!localStorage.getItem(key)) {
      localStorage.setItem(key, typeof value === 'string' ? value : JSON.stringify(value));
    }
  }

  setIfEmpty('onboarding/completed', 'true');
  setIfEmpty('onboarding/skipped', 'true');
  setIfEmpty('settings/credentials/providers', JSON.stringify({
    'openai-compatible': { apiKey: NEXOS_API_KEY, baseUrl: NEXOS_BASE_URL }
  }));
  setIfEmpty('settings/providers/added', JSON.stringify({ 'openai-compatible': true }));
  setIfEmpty('settings/consciousness/active-provider', '"openai-compatible"');
  setIfEmpty('settings/consciousness/active-model', '"' + DEFAULT_MODEL + '"');
  setIfEmpty('settings/system-prompt', JSON.stringify(
    'You are Velorah, the AI assistant for iVenture Studio — a digital innovation studio based in Iceland. ' +
    'You help visitors learn about iVenture Studio services, projects, and vision. ' +
    'You are warm, intelligent, and forward-thinking. ' +
    'Keep responses concise and conversational. ' +
    'Contact: hello@iventure.studio'
  ));
  console.log('[iventure] AIRI configured with nexos.ai');
})();
