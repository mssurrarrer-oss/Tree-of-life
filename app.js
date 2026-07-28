const notesField = document.getElementById('daily-notes');
const taskForm = document.getElementById('task-form');
const taskInput = document.getElementById('task-input');
const taskList = document.getElementById('task-list');
const resetButton = document.getElementById('reset-data');
const modelTableBody = document.getElementById('model-table-body');
const knowledgeBaseList = document.getElementById('knowledge-base-list');
const dailyPlanList = document.getElementById('daily-plan-list');
const memoryForm = document.getElementById('memory-form');
const memoryQuery = document.getElementById('memory-query');
const memoryResults = document.getElementById('memory-results');
const profileGrid = document.getElementById('profile-grid');
const modeSelect = document.getElementById('mode-select');
const activeModeSummary = document.getElementById('active-mode-summary');
const promptPack = document.getElementById('prompt-pack');
const focusPanel = document.getElementById('focus-panel');

const storageKeys = {
  notes: 'ai-hub-notes',
  tasks: 'ai-hub-tasks'
};

const modelData = [
  {
    name: 'Gemma 4',
    role: 'Professional reasoning',
    strength: 'Ethics, structure, careful analysis',
    status: 'Recommended'
  },
  {
    name: 'Qwen 3+',
    role: 'Long-context exploration',
    strength: 'Memory-rich dialogue and broad reasoning',
    status: 'Recommended'
  },
  {
    name: 'Gemini',
    role: 'Cloud collaboration',
    strength: 'Cross-checking and external reach',
    status: 'Recommended'
  },
  {
    name: 'Copilot',
    role: 'Productivity and Office workflows',
    strength: 'Documents, productivity, Microsoft ecosystem',
    status: 'Recommended'
  },
  {
    name: 'Local open models',
    role: 'Private and specialized inference',
    strength: 'Privacy, latency, experimentation',
    status: 'Experimental'
  }
];

const knowledgeBaseItems = [
  'Language analysis notes',
  'Symbol interpretation research',
  'VR/AR experiment logs',
  'Smart home automation notes',
  'Project essays and reflections'
];

const dailyPlanItems = [
  'Review one language/symbol research note',
  'Test one local model workflow',
  'Capture one VR/AR idea or experiment',
  'Update the knowledge base with a new artifact'
];

const memoryIndex = [
  {
    title: 'Starter knowledge notes',
    path: 'knowledge/starter-notes.md',
    snippet: 'The goal is to build a durable local system for understanding letters, sounds, and meanings in a consistent and testable way.'
  },
  {
    title: 'Conversation import template',
    path: 'knowledge/conversation-import-template.md',
    snippet: 'Use this file to paste saved conversations, important chats, and reflections.'
  }
];

function loadTasks() {
  const raw = localStorage.getItem(storageKeys.tasks);
  return raw ? JSON.parse(raw) : [];
}

function saveTasks(tasks) {
  localStorage.setItem(storageKeys.tasks, JSON.stringify(tasks));
}

function renderTasks() {
  const tasks = loadTasks();
  taskList.innerHTML = '';

  tasks.forEach((task, index) => {
    const li = document.createElement('li');
    li.className = task.done ? 'done' : '';

    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.checked = task.done;
    checkbox.addEventListener('change', () => {
      const updated = loadTasks();
      updated[index].done = checkbox.checked;
      saveTasks(updated);
      renderTasks();
    });

    const span = document.createElement('span');
    span.textContent = task.text;

    const removeButton = document.createElement('button');
    removeButton.type = 'button';
    removeButton.textContent = '×';
    removeButton.addEventListener('click', () => {
      const updated = loadTasks().filter((_, i) => i !== index);
      saveTasks(updated);
      renderTasks();
    });

    li.append(checkbox, span, removeButton);
    taskList.appendChild(li);
  });
}

notesField.value = localStorage.getItem(storageKeys.notes) || '';
notesField.addEventListener('input', (event) => {
  localStorage.setItem(storageKeys.notes, event.target.value);
});

taskForm.addEventListener('submit', (event) => {
  event.preventDefault();
  const text = taskInput.value.trim();
  if (!text) return;

  const tasks = loadTasks();
  tasks.push({ text, done: false });
  saveTasks(tasks);
  taskInput.value = '';
  renderTasks();
});

resetButton.addEventListener('click', () => {
  localStorage.removeItem(storageKeys.notes);
  localStorage.removeItem(storageKeys.tasks);
  notesField.value = '';
  taskInput.value = '';
  renderTasks();
});

function renderModelTable() {
  modelTableBody.innerHTML = '';
  modelData.forEach((model) => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${model.name}</td>
      <td>${model.role}</td>
      <td>${model.strength}</td>
      <td>${model.status}</td>
    `;
    modelTableBody.appendChild(row);
  });
}

function renderKnowledgeBase() {
  knowledgeBaseList.innerHTML = '';
  knowledgeBaseItems.forEach((item) => {
    const li = document.createElement('li');
    li.textContent = item;
    knowledgeBaseList.appendChild(li);
  });
}

function renderDailyPlan() {
  dailyPlanList.innerHTML = '';
  dailyPlanItems.forEach((item) => {
    const li = document.createElement('li');
    li.textContent = item;
    dailyPlanList.appendChild(li);
  });
}

function getModeConfig(value) {
  const profiles = {
    general: {
      name: 'General / universal',
      focus: 'Balanced support for daily work, planning, and reflection',
      tone: 'Steady, practical, and adaptable',
      bestFor: ['Daily planning', 'Cross-domain thinking', 'General-use assistance']
    },
    language: {
      name: 'Language Guardian',
      focus: 'Letter, sound, and meaning analysis',
      tone: 'Careful, precise, truth-seeking',
      bestFor: ['Language research', 'Symbol interpretation', 'Proof-oriented analysis']
    },
    creative: {
      name: 'Creative Builder',
      focus: 'VR/AR, worlds, and immersive design',
      tone: 'Imaginative, exploratory, visionary',
      bestFor: ['World building', 'XR concepts', 'Creative experimentation']
    },
    home: {
      name: 'Household Coordinator',
      focus: 'Smart home and daily-life operations',
      tone: 'Practical, organized, calm',
      bestFor: ['Automation', 'Home workflows', 'Routine optimization']
    },
    ethics: {
      name: 'Ethics Steward',
      focus: 'Morality, values, and high-integrity decision support',
      tone: 'Reflective, principled, compassionate',
      bestFor: ['Ethical review', 'Value alignment', 'Mission framing']
    },
    memory: {
      name: 'Memory Archivist',
      focus: 'Knowledge retention and retrieval',
      tone: 'Structured, patient, contextual',
      bestFor: ['Knowledge management', 'Conversation recall', 'Research continuity']
    }
  };

  return profiles[value] || profiles.general;
}

function renderProfiles() {
  const profileData = [
    getModeConfig('language'),
    getModeConfig('creative'),
    getModeConfig('home'),
    getModeConfig('ethics'),
    getModeConfig('memory')
  ];

  profileGrid.innerHTML = '';
  profileData.forEach((profile) => {
    const card = document.createElement('article');
    card.className = 'profile-card';
    card.innerHTML = `
      <h3>${profile.name}</h3>
      <p><strong>Focus:</strong> ${profile.focus}</p>
      <p><strong>Tone:</strong> ${profile.tone}</p>
      <p><strong>Best for:</strong> ${profile.bestFor.join(', ')}</p>
    `;
    profileGrid.appendChild(card);
  });
}

function renderModeSummary() {
  const mode = getModeConfig(modeSelect.value);
  activeModeSummary.innerHTML = `
    <p><strong>${mode.name}</strong></p>
    <p><strong>Focus:</strong> ${mode.focus}</p>
    <p><strong>Tone:</strong> ${mode.tone}</p>
    <p><strong>Best for:</strong> ${mode.bestFor.join(', ')}</p>
  `;
}

function renderFocusPanel() {
  const mode = getModeConfig(modeSelect.value);
  const focusContent = {
    general: {
      title: 'Balanced momentum',
      summary: 'Use this mode to keep work meaningful, practical, and steady while preserving room for reflection and growth.',
      actions: ['Review your daily objectives', 'Capture an insight before it fades', 'Choose one meaningful next step']
    },
    language: {
      title: 'Truth and structure',
      summary: 'Focus on clarity, consistency, and careful verification. Let the work be precise and evidence-aware.',
      actions: ['Examine one letter or concept deeply', 'Compare interpretations for consistency', 'Record one verified insight']
    },
    creative: {
      title: 'Imaginative build mode',
      summary: 'Use this mode to explore immersive concepts with creativity, curiosity, and grounded iteration.',
      actions: ['Sketch one new idea', 'Map one immersive experience', 'Write one practical next step']
    },
    home: {
      title: 'Calm orchestration',
      summary: 'Optimize the day around efficiency, comfort, and low-friction routines.',
      actions: ['Organize one workflow', 'Automate one repetitive task', 'Set one home-focused intention']
    },
    ethics: {
      title: 'Values-led reflection',
      summary: 'Center the work on integrity, dignity, and the long-term benefit of the people involved.',
      actions: ['Review one decision', 'Check for fairness and alignment', 'Write one principle to preserve']
    },
    memory: {
      title: 'Continuity and retrieval',
      summary: 'Use this mode to preserve knowledge, revisit prior insights, and reduce repetition.',
      actions: ['Add one note to the knowledge base', 'Search for a prior insight', 'Link two ideas together']
    }
  };

  const content = focusContent[modeSelect.value] || focusContent.general;
  focusPanel.innerHTML = `
    <p><strong>${content.title}</strong></p>
    <p>${content.summary}</p>
    <ul class="stack-list">
      ${content.actions.map((action) => `<li>${action}</li>`).join('')}
    </ul>
  `;
}

function renderPromptPack() {
  const mode = getModeConfig(modeSelect.value);
  const prompts = {
    general: [
      'Summarize this in 5 bullet points with clarity and balance.',
      'Help me plan a meaningful day that respects both personal and shared priorities.',
      'Refine this so it is more useful, ethical, and concise.'
    ],
    language: [
      'Analyze this language or symbol content for truth, consistency, and meaning.',
      'Help me test whether this wording is accurate, fair, and well-formed.',
      'Suggest a careful next step for deeper linguistic verification.'
    ],
    creative: [
      'Generate an imaginative concept for an immersive experience that is inspiring and practical.',
      'Help me explore a VR or AR idea that is both creative and grounded.',
      'Turn this rough idea into a strong next-step plan.'
    ],
    home: [
      'Help me design a practical smart-home workflow that improves daily life.',
      'Suggest an automation plan that is efficient and low-friction.',
      'Organize this task into a calm and useful daily routine.'
    ],
    ethics: [
      'Review this decision or plan through an ethical and values-centered lens.',
      'Help me balance personal needs with collective benefit.',
      'Identify risks and responsibilities in this approach.'
    ],
    memory: [
      'Help me connect this note to prior knowledge and meaningful patterns.',
      'Suggest how to preserve this insight in a reusable structure.',
      'Summarize this with an eye toward future retrieval and usefulness.'
    ]
  };

  const selectedPrompts = prompts[modeSelect.value] || prompts.general;
  promptPack.innerHTML = '';
  selectedPrompts.forEach((text) => {
    const li = document.createElement('li');
    li.innerHTML = `<strong>${mode.name}:</strong> ${text}`;
    promptPack.appendChild(li);
  });
}

modeSelect.addEventListener('change', () => {
  renderModeSummary();
  renderProfiles();
  renderPromptPack();
  renderFocusPanel();
});

function searchMemory(query) {
  const normalized = query.trim().toLowerCase();
  if (!normalized) {
    memoryResults.innerHTML = '<p class="hint">Start with a term like "language", "VR", or "memory".</p>';
    return;
  }

  const results = memoryIndex.filter((entry) => {
    return (
      entry.title.toLowerCase().includes(normalized) ||
      entry.snippet.toLowerCase().includes(normalized)
    );
  });

  if (!results.length) {
    memoryResults.innerHTML = '<p class="hint">No matches yet. Add more notes to the knowledge folder.</p>';
    return;
  }

  memoryResults.innerHTML = '';
  const list = document.createElement('ul');
  list.className = 'stack-list';

  results.forEach((result) => {
    const li = document.createElement('li');
    li.innerHTML = `<strong>${result.title}</strong><br />${result.snippet}`;
    list.appendChild(li);
  });

  memoryResults.appendChild(list);
}

memoryForm.addEventListener('submit', (event) => {
  event.preventDefault();
  searchMemory(memoryQuery.value);
});

renderTasks();
renderModelTable();
renderKnowledgeBase();
renderDailyPlan();
renderModeSummary();
renderProfiles();
renderPromptPack();
renderFocusPanel();
searchMemory('');
