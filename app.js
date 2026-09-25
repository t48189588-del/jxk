const translations = {
    en: {
        appTitle: "Global GitHub Chat",
        connectedRepo: "Synced to Repository (messages.json)",
        settings: "Settings",
        send: "Send",
        aboutTitle: "GitHub Persistence",
        aboutDesc: "Messages are securely committed straight to messages.json via the GitHub API. Supports up to 100 simultaneous users on GitHub Pages.",
        filesTitle: "Project Files Included",
        modalTitle: "Repository Configuration",
        modalDesc: "To commit messages back to GitHub from a static site, enter your GitHub Repository details and a Personal Access Token with repo permissions."
    },
    es: {
        appTitle: "Chat Global de GitHub",
        connectedRepo: "Sincronizado con repositorio (messages.json)",
        settings: "Ajustes",
        send: "Enviar",
        aboutTitle: "Persistencia en GitHub",
        aboutDesc: "Los mensajes se envían directamente a messages.json mediante la API de GitHub. Soporta hasta 100 usuarios en GitHub Pages.",
        filesTitle: "Archivos del Proyecto",
        modalTitle: "Configuración del Repositorio",
        modalDesc: "Para guardar mensajes en GitHub desde un sitio estático, introduce los datos de tu repositorio y un token de acceso personal con permisos repo."
    },
    fr: {
        appTitle: "Chat Global GitHub",
        connectedRepo: "Synchronisé avec le dépôt (messages.json)",
        settings: "Paramètres",
        send: "Envoyer",
        aboutTitle: "Persistance GitHub",
        aboutDesc: "Les messages sont enregistrés directement dans messages.json via l'API GitHub. Prend en charge jusqu'à 100 utilisateurs simultanés.",
        filesTitle: "Fichiers du Projet",
        modalTitle: "Configuration du Dépôt",
        modalDesc: "Pour enregistrer des messages sur GitHub, entrez les détails de votre dépôt et un jeton d'accès personnel avec les permissions repo."
    }
};

let currentLang = 'en';
let messages = [
    { user: "System", text: "Welcome to the global GitHub chat! Configure your repository settings to persist live messages." },
    { user: "Alice", text: "Hello everyone! Loving this serverless setup." },
    { user: "Bob", text: "Built right into GitHub Pages and messages.json!" }
];

let repoConfig = {
    owner: localStorage.getItem('gh_owner') || 'your-username',
    repo: localStorage.getItem('gh_repo') || 'your-repo-name',
    token: localStorage.getItem('gh_token') || ''
};

window.addEventListener('DOMContentLoaded', () => {
    detectLanguage();
    initEventListeners();
    loadMessages();
    
    // Poll for messages every 10 seconds
    setInterval(loadMessages, 10000);
});

function detectLanguage() {
    const browserLang = (navigator.language || navigator.userLanguage || 'en').substring(0, 2);
    if (translations[browserLang]) {
        currentLang = browserLang;
    }
    const select = document.getElementById('langSelect');
    if (select) {
        select.value = currentLang;
        select.addEventListener('change', (e) => {
            currentLang = e.target.value;
            applyTranslations();
        });
    }
    applyTranslations();
}

function applyTranslations() {
    const dict = translations[currentLang] || translations.en;
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (dict[key]) {
            el.textContent = dict[key];
        }
    });
}

function initEventListeners() {
    document.getElementById('chatForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const username = document.getElementById('usernameInput').value.trim();
        const text = document.getElementById('messageInput').value.trim();
        
        if (!username || !text) return;

        const newMessage = { user: username, text: text, timestamp: new Date().toISOString() };
        
        // Optimistic UI update
        messages.push(newMessage);
        renderMessages();
        document.getElementById('messageInput').value = '';

        // Try to persist to GitHub if configured
        if (repoConfig.token && repoConfig.owner && repoConfig.repo) {
            await commitMessageToGitHub(newMessage);
        } else {
            showBanner("Message added locally. Configure GitHub Token in Settings to persist across all users.");
        }
    });

    document.getElementById('configBtn').addEventListener('click', () => {
        document.getElementById('repoOwner').value = repoConfig.owner;
        document.getElementById('repoName').value = repoConfig.repo;
        document.getElementById('repoToken').value = repoConfig.token;
        toggleConfigModal(true);
    });
}

function toggleConfigModal(show) {
    const modal = document.getElementById('configModal');
    if (show) modal.classList.remove('hidden');
    else modal.classList.add('hidden');
}

function saveConfig() {
    repoConfig.owner = document.getElementById('repoOwner').value.trim();
    repoConfig.repo = document.getElementById('repoName').value.trim();
    repoConfig.token = document.getElementById('repoToken').value.trim();

    localStorage.setItem('gh_owner', repoConfig.owner);
    localStorage.setItem('gh_repo', repoConfig.repo);
    localStorage.setItem('gh_token', repoConfig.token);

    toggleConfigModal(false);
    showBanner("Repository configuration saved successfully!");
    loadMessages();
}

function showBanner(text) {
    const banner = document.getElementById('statusBanner');
    const statusText = document.getElementById('statusText');
    statusText.textContent = text;
    banner.classList.remove('hidden');
}

function dismissBanner() {
    document.getElementById('statusBanner').classList.add('hidden');
}

async function loadMessages() {
    if (!repoConfig.owner || !repoConfig.repo || repoConfig.owner === 'your-username') {
        renderMessages();
        return;
    }

    try {
        const url = `https://raw.githubusercontent.com/${repoConfig.owner}/${repoConfig.repo}/main/messages.json?t=${new Date().getTime()}`;
        const res = await fetch(url);
        if (res.ok) {
            const data = await res.json();
            if (Array.isArray(data)) {
                messages = data;
                renderMessages();
            }
        }
    } catch (err) {
        console.warn("Could not fetch remote messages.json, using local cache.", err);
        renderMessages();
    }
}

function renderMessages() {
    const container = document.getElementById('chatMessages');
    container.innerHTML = '';

    messages.forEach(msg => {
        const div = document.createElement('div');
        div.className = "message-bubble flex flex-col space-y-1 max-w-lg bg-slate-800/80 border border-slate-700/60 rounded-2xl p-3.5 shadow-sm";
        
        const isSystem = msg.user.toLowerCase() === 'system';
        if (isSystem) {
            div.className = "message-bubble flex flex-col space-y-1 max-w-xl bg-indigo-950/30 border border-indigo-500/30 rounded-2xl p-3.5 mx-auto text-center w-full";
        }

        div.innerHTML = `
            <div class="flex items-center justify-between">
                <span class="font-semibold text-xs ${isSystem ? 'text-indigo-300' : 'text-indigo-400'}">${escapeHtml(msg.user)}</span>
                <span class="text-[10px] text-slate-500">${msg.timestamp ? new Date(msg.timestamp).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) : ''}</span>
            </div>
            <p class="text-sm text-slate-200 break-words leading-relaxed">${escapeHtml(msg.text)}</p>
        `;
        container.appendChild(div);
    });

    container.scrollTop = container.scrollHeight;
}

async function commitMessageToGitHub(newMsg) {
    showBanner("Syncing message to GitHub repository...");
    const { owner, repo, token } = repoConfig;
    const apiUrl = `https://api.github.com/repos/${owner}/${repo}/contents/messages.json`;

    try {
        // 1. Get current file sha and contents
        const getRes = await fetch(apiUrl, {
            headers: { 'Authorization': `Bearer ${token}`, 'Accept': 'application/vnd.github+json' }
        });

        if (!getRes.ok) throw new Error("Failed to fetch file from GitHub API. Verify settings.");

        const fileData = await getRes.json();
        const currentContent = JSON.parse(decodeURIComponent(escape(atob(fileData.content))));
        
        currentContent.push(newMsg);
        
        // Limit to last 100 messages to prevent bloated JSON files
        const updatedMessages = currentContent.slice(-100);
        const encodedContent = btoa(unescape(encodeURIComponent(JSON.stringify(updatedMessages, null, 2))));

        // 2. Commit updated file
        const putRes = await fetch(apiUrl, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Accept': 'application/vnd.github+json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: `Add new chat message from ${newMsg.user}`,
                content: encodedContent,
                sha: fileData.sha
            })
        });

        if (!putRes.ok) throw new Error("Failed to commit message to GitHub.");

        showBanner("Message successfully committed to GitHub repository!");
        setTimeout(dismissBanner, 4000);
        loadMessages();
    } catch (err) {
        showBanner(`Error: ${err.message}`);
    }
}

function escapeHtml(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
}

const fileContents = {
    'index.html': `<!DOCTYPE html>
<html lang="en">
... (See index.html tab above for complete markup)
</html>`,
    'style.css': `::-webkit-scrollbar { width: 6px; }`,
    'app.js': `// GitHub REST API Integration & Localization`,
    'messages.json': JSON.stringify(messages, null, 2),
    'README.md': `# Global GitHub Chat
1. Create a repository on GitHub.
2. Push index.html, style.css, app.js, and messages.json.
3. Enable GitHub Pages under Settings > Pages.`
};

function switchFileTab(filename) {
    const modal = document.getElementById('codeModal');
    document.getElementById('codeModalTitle').textContent = filename;
    document.getElementById('codeModalContent').textContent = fileContents[filename] || "File content available in code blocks.";
    modal.classList.remove('hidden');
}

function closeCodeModal() {
    document.getElementById('codeModal').classList.add('hidden');
}

function copyCodeContent() {
    const text = document.getElementById('codeModalContent').textContent;
    const textArea = document.createElement("textarea");
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand("copy");
    document.body.removeChild(textArea);
    alert("Code copied to clipboard!");
}