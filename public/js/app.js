// MakerQuest Client Application Controller
class MakerAppController {
  constructor() {
    this.token = localStorage.getItem('mq_token') || null;
    this.currentUser = null;
    this.dashboardData = null;
    this.currentView = 'map'; // 'map' | 'projects' | 'challenges' | 'badges'
    this.projectFilterLevel = 'all'; // 'all' | 1 | 2 | 3 | 4
    this.projectSearchQuery = '';

    this.levelMapRenderer = null;
    this.projectModal = null;
    this.challengeModal = null;
  }

  getToken() {
    return this.token;
  }

  setToken(t) {
    this.token = t;
    if (t) {
      localStorage.setItem('mq_token', t);
    } else {
      localStorage.removeItem('mq_token');
    }
  }

  async init() {
    console.log('🚀 Initializing MakerQuest Web Application...');

    // Instantiate modals & renderers
    this.levelMapRenderer = new LevelMapRenderer('level-map-container');
    window.projectModal = new ProjectModal();
    window.challengeModal = new ChallengeModal();

    this.setupEventListeners();
    this.setupAudioToggle();

    // Check existing auth or default to Alex demo student
    if (this.token) {
      try {
        const res = await fetch('/api/auth/me', {
          headers: { 'Authorization': `Bearer ${this.token}` }
        });
        if (res.ok) {
          const data = await res.json();
          this.currentUser = data.user;
          this.showApp();
          return;
        }
      } catch (e) {
        console.warn('Session check failed:', e);
      }
    }

    // Default auto-login to demo student Alex Rivera for instant smooth experience
    await this.demoLogin('alex@makerquest.edu');
  }

  setupEventListeners() {
    // Navigation Tabs
    document.querySelectorAll('.nav-tab').forEach(tab => {
      tab.addEventListener('click', (e) => {
        window.soundFx.playClick();
        const view = e.currentTarget.getAttribute('data-view');
        this.switchView(view);
      });
    });

    // Mobile Menu Toggle
    const mobileMenuBtn = document.getElementById('btn-mobile-menu');
    const navLinks = document.getElementById('nav-links-menu');
    if (mobileMenuBtn && navLinks) {
      mobileMenuBtn.addEventListener('click', () => {
        navLinks.classList.toggle('open');
      });
    }

    // Quick Login / Switch Student Dropdown
    const userProfileTrigger = document.getElementById('user-profile-trigger');
    const userDropdown = document.getElementById('user-profile-dropdown');
    if (userProfileTrigger && userDropdown) {
      userProfileTrigger.addEventListener('click', (e) => {
        e.stopPropagation();
        userDropdown.classList.toggle('hidden');
      });
      document.addEventListener('click', () => {
        userDropdown.classList.add('hidden');
      });
    }

    // Demo student quick switch buttons
    document.querySelectorAll('.btn-switch-demo-user').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        window.soundFx.playClick();
        const email = e.currentTarget.getAttribute('data-email');
        await this.demoLogin(email);
      });
    });

    // Logout button
    const logoutBtn = document.getElementById('btn-logout');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', async () => {
        window.soundFx.playClick();
        await fetch('/api/auth/logout', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${this.token}` }
        });
        this.setToken(null);
        this.currentUser = null;
        this.showAuthModal();
      });
    }

    // Auth Modal Forms
    const authModal = document.getElementById('auth-modal');
    const authTabLogin = document.getElementById('auth-tab-login');
    const authTabRegister = document.getElementById('auth-tab-register');
    const formLogin = document.getElementById('form-login');
    const formRegister = document.getElementById('form-register');

    if (authTabLogin && authTabRegister) {
      authTabLogin.addEventListener('click', () => {
        authTabLogin.classList.add('active');
        authTabRegister.classList.remove('active');
        formLogin.classList.remove('hidden');
        formRegister.classList.add('hidden');
      });
      authTabRegister.addEventListener('click', () => {
        authTabRegister.classList.add('active');
        authTabLogin.classList.remove('active');
        formRegister.classList.remove('hidden');
        formLogin.classList.add('hidden');
      });
    }

    if (formLogin) {
      formLogin.addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('login-email').value;
        const password = document.getElementById('login-password').value;
        try {
          const res = await fetch('/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
          });
          const data = await res.json();
          if (!res.ok) throw new Error(data.error || 'Login failed');
          this.setToken(data.token);
          this.currentUser = data.user;
          this.hideAuthModal();
          this.showApp();
        } catch (err) {
          alert(err.message);
        }
      });
    }

    if (formRegister) {
      formRegister.addEventListener('submit', async (e) => {
        e.preventDefault();
        const name = document.getElementById('reg-name').value;
        const email = document.getElementById('reg-email').value;
        const password = document.getElementById('reg-password').value;
        const avatar = document.getElementById('reg-avatar').value || '🚀';
        try {
          const res = await fetch('/api/auth/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name, email, password, avatar })
          });
          const data = await res.json();
          if (!res.ok) throw new Error(data.error || 'Registration failed');
          this.setToken(data.token);
          this.currentUser = data.user;
          this.hideAuthModal();
          this.showApp();
          window.soundFx.playFanfare();
          window.confetti.fire({ count: 90 });
          this.showRewardModal({
            title: 'Welcome to MakerQuest!',
            message: 'Your student account is created! Earned the "First Spark" badge and +50 XP bonus!',
            icon: '⚡',
            xp: 50
          });
        } catch (err) {
          alert(err.message);
        }
      });
    }

    // Projects Search & Filter
    const searchInput = document.getElementById('projects-search');
    if (searchInput) {
      searchInput.addEventListener('input', (e) => {
        this.projectSearchQuery = e.target.value.toLowerCase().trim();
        this.renderProjectsGrid();
      });
    }

    document.querySelectorAll('.filter-chip').forEach(chip => {
      chip.addEventListener('click', (e) => {
        window.soundFx.playClick();
        document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
        e.currentTarget.classList.add('active');
        this.projectFilterLevel = e.currentTarget.getAttribute('data-level');
        this.renderProjectsGrid();
      });
    });

    // Reward Modal Close
    const rewardModal = document.getElementById('reward-modal');
    if (rewardModal) {
      rewardModal.querySelector('.modal-close-btn').addEventListener('click', () => {
        rewardModal.classList.add('hidden');
      });
      rewardModal.addEventListener('click', (e) => {
        if (e.target === rewardModal) rewardModal.classList.add('hidden');
      });
    }
  }

  setupAudioToggle() {
    const muteBtn = document.getElementById('btn-sound-toggle');
    if (muteBtn) {
      const updateIcon = () => {
        const isMuted = window.soundFx.isMuted();
        muteBtn.innerHTML = isMuted ? '🔇' : '🔊';
        muteBtn.title = isMuted ? 'Sound Muted (Click to enable)' : 'Sound Enabled (Click to mute)';
      };
      updateIcon();
      muteBtn.addEventListener('click', () => {
        window.soundFx.toggleMute();
        updateIcon();
        if (!window.soundFx.isMuted()) {
          window.soundFx.playCheck();
        }
      });
    }
  }

  async demoLogin(email) {
    try {
      const res = await fetch('/api/auth/demo-login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email })
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error);
      this.setToken(data.token);
      this.currentUser = data.user;
      this.hideAuthModal();
      this.showApp();
    } catch (e) {
      console.error('Demo login error:', e);
      this.showAuthModal();
    }
  }

  showAuthModal() {
    document.getElementById('auth-modal').classList.remove('hidden');
    document.getElementById('app-main-content').classList.add('hidden');
  }

  hideAuthModal() {
    document.getElementById('auth-modal').classList.add('hidden');
    document.getElementById('app-main-content').classList.remove('hidden');
  }

  switchView(viewName) {
    this.currentView = viewName;
    document.querySelectorAll('.nav-tab').forEach(t => {
      if (t.getAttribute('data-view') === viewName) {
        t.classList.add('active');
      } else {
        t.classList.remove('active');
      }
    });

    // Close mobile menu if open
    const navLinks = document.getElementById('nav-links-menu');
    if (navLinks) navLinks.classList.remove('open');

    // Toggle views
    document.querySelectorAll('.view-panel').forEach(panel => {
      if (panel.id === `view-${viewName}`) {
        panel.classList.remove('hidden');
      } else {
        panel.classList.add('hidden');
      }
    });

    if (viewName === 'projects') {
      this.renderProjectsGrid();
    } else if (viewName === 'challenges') {
      this.renderChallengesGrid();
    } else if (viewName === 'badges') {
      this.renderBadgesGrid();
    }
  }

  async showApp() {
    this.hideAuthModal();
    await this.refreshDashboard();
  }

  async refreshDashboard() {
    if (!this.token) return;

    try {
      const res = await fetch('/api/dashboard', {
        headers: { 'Authorization': `Bearer ${this.token}` }
      });
      if (!res.ok) throw new Error('Failed to fetch dashboard');
      const data = await res.json();
      this.dashboardData = data;
      this.currentUser = data.user;

      this.updateHeaderStats(data.user);
      this.renderHeroBanner(data.user, data.next_recommended_project);

      // Render Level Progression Map (Level 2)
      this.levelMapRenderer.render(
        data.level_map,
        data.user,
        (selectedLevel) => {
          this.projectFilterLevel = String(selectedLevel);
          this.switchView('projects');
          // update filter pill
          document.querySelectorAll('.filter-chip').forEach(c => {
            if (c.getAttribute('data-level') === String(selectedLevel)) {
              c.classList.add('active');
            } else {
              c.classList.remove('active');
            }
          });
        },
        (challengeId) => {
          window.challengeModal.open(challengeId);
        }
      );

      // Also refresh background views if active
      if (this.currentView === 'projects') this.renderProjectsGrid();
      if (this.currentView === 'challenges') this.renderChallengesGrid();
      if (this.currentView === 'badges') this.renderBadgesGrid();

    } catch (err) {
      console.error('Error refreshing dashboard:', err);
    }
  }

  updateHeaderStats(user) {
    document.getElementById('header-avatar').textContent = user.avatar || '🚀';
    document.getElementById('header-student-name').textContent = user.name;
    document.getElementById('header-user-level').textContent = `Lvl ${user.current_level}`;
    document.getElementById('header-user-xp').textContent = `${user.current_xp} XP`;
    document.getElementById('header-user-streak').textContent = `${user.streak_days} 🔥`;
  }

  renderHeroBanner(user, nextProj) {
    const container = document.getElementById('dashboard-hero-banner');
    if (!container) return;

    container.innerHTML = `
      <div class="hero-card">
        <div class="hero-main-row">
          <div class="hero-student-meta">
            <div class="hero-avatar-bubble">${user.avatar}</div>
            <div class="hero-greeting">
              <span class="hero-badge-tag">Workshop Cadet: ${user.name}</span>
              <h1 class="hero-tier-title">Level ${user.current_level}: ${user.level_title}</h1>
              <p class="hero-subtext">Mastering realm: <strong>${user.level_theme}</strong></p>
            </div>
          </div>

          <div class="hero-xp-meter-box">
            <div class="xp-meter-label-row">
              <span class="xp-progress-label">Level Progression</span>
              <span class="xp-progress-digits"><strong>${user.current_xp}</strong> / ${user.xp_for_next_level} XP</span>
            </div>
            <div class="hero-xp-track">
              <div class="hero-xp-fill" style="width: ${user.xp_progress_percent}%"></div>
            </div>
            <div class="xp-footnote">${user.xp_progress_percent}% completed towards Level ${user.current_level + 1}</div>
          </div>
        </div>

        <div class="hero-stats-row">
          <div class="stat-box">
            <span class="stat-icon">⚡</span>
            <div class="stat-text">
              <span class="stat-num">${user.current_xp}</span>
              <span class="stat-lbl">Total XP</span>
            </div>
          </div>
          <div class="stat-box">
            <span class="stat-icon">📦</span>
            <div class="stat-text">
              <span class="stat-num">${user.completed_projects_count}</span>
              <span class="stat-lbl">DIY Projects Done</span>
            </div>
          </div>
          <div class="stat-box">
            <span class="stat-icon">🎯</span>
            <div class="stat-text">
              <span class="stat-num">${user.completed_challenges_count}</span>
              <span class="stat-lbl">Checkpoints Passed</span>
            </div>
          </div>
          <div class="stat-box">
            <span class="stat-icon">🏅</span>
            <div class="stat-text">
              <span class="stat-num">${user.earned_badges_count} / ${user.total_badges_count}</span>
              <span class="stat-lbl">Badges Earned</span>
            </div>
          </div>
        </div>

        ${nextProj ? `
          <div class="hero-recommended-bar">
            <div class="rec-left">
              <span class="rec-icon">⚡ Recommended Mission:</span>
              <strong class="rec-title">${nextProj.title}</strong>
              <span class="rec-category">(${nextProj.category})</span>
            </div>
            <button class="btn btn-sm btn-primary btn-launch-rec" data-project-id="${nextProj.id}">
              Launch Blueprint (+${nextProj.xp_reward} XP) 🚀
            </button>
          </div>
        ` : ''}
      </div>
    `;

    const launchRecBtn = container.querySelector('.btn-launch-rec');
    if (launchRecBtn) {
      launchRecBtn.addEventListener('click', (e) => {
        const pId = e.currentTarget.getAttribute('data-project-id');
        window.projectModal.open(pId, () => this.refreshDashboard());
      });
    }
  }

  async renderProjectsGrid() {
    const grid = document.getElementById('projects-grid-container');
    if (!grid) return;

    grid.innerHTML = `
      <div class="loading-state">
        <div class="spinner"></div>
        <p>Loading DIY Engineering Projects...</p>
      </div>
    `;

    try {
      const res = await fetch('/api/projects', {
        headers: { 'Authorization': `Bearer ${this.token}` }
      });
      const data = await res.json();
      const allProjects = data.projects || [];

      // Filter by level and search
      const filtered = allProjects.filter(p => {
        const matchesLevel = this.projectFilterLevel === 'all'
          ? true
          : this.projectFilterLevel === 'completed'
            ? p.status === 'completed'
            : String(p.level_required) === this.projectFilterLevel;

        const matchesSearch = !this.projectSearchQuery
          || p.title.toLowerCase().includes(this.projectSearchQuery)
          || p.description.toLowerCase().includes(this.projectSearchQuery)
          || p.category.toLowerCase().includes(this.projectSearchQuery);

        return matchesLevel && matchesSearch;
      });

      if (filtered.length === 0) {
        grid.innerHTML = `
          <div class="empty-state">
            <span class="empty-icon">🔍</span>
            <h3>No DIY Projects Found</h3>
            <p>Try tweaking your search terms or filter selection.</p>
          </div>
        `;
        return;
      }

      grid.innerHTML = filtered.map(p => {
        const isLocked = !p.is_unlocked;
        const isCompleted = p.status === 'completed';
        const materialsTotal = p.materials_count || 1;
        const materialsGathered = p.materials_gathered_count || 0;
        const gatherPercent = Math.round((materialsGathered / materialsTotal) * 100);

        return `
          <div class="project-card ${isLocked ? 'locked' : ''} ${isCompleted ? 'completed' : ''}">
            <div class="project-card-header">
              <div class="project-card-meta">
                <span class="badge-pill level-pill">Level ${p.level_required}</span>
                <span class="badge-pill category-pill">${p.category}</span>
              </div>
              <span class="project-xp-reward">+${p.xp_reward} XP</span>
            </div>

            <div class="project-card-body">
              <h3 class="project-card-title">${p.title}</h3>
              <p class="project-card-description">${p.description}</p>

              <div class="project-card-stats">
                <span class="stat-tag">⏱️ ${p.estimated_time}</span>
                <span class="stat-tag">📊 ${p.difficulty}</span>
                <span class="stat-tag">🛠️ ${p.steps_count} Steps</span>
              </div>

              <!-- Materials Gathered Progress Bar -->
              <div class="card-checklist-meter">
                <div class="meter-info">
                  <span>Materials Gathered</span>
                  <strong>${materialsGathered} / ${materialsTotal}</strong>
                </div>
                <div class="mini-progress-track">
                  <div class="mini-progress-fill" style="width: ${gatherPercent}%"></div>
                </div>
              </div>
            </div>

            <div class="project-card-footer">
              ${isLocked ? `
                <div class="locked-footer">
                  <span class="locked-msg">🔒 ${p.unlock_reason}</span>
                </div>
              ` : `
                <button class="btn ${isCompleted ? 'btn-success' : 'btn-primary'} btn-block btn-open-project" data-id="${p.id}">
                  ${isCompleted ? '🏆 Review Completed Project' : '🛠️ Open DIY Blueprint & Checklist'}
                </button>
              `}
            </div>
          </div>
        `;
      }).join('');

      // Attach open events
      grid.querySelectorAll('.btn-open-project').forEach(btn => {
        btn.addEventListener('click', (e) => {
          const pId = e.currentTarget.getAttribute('data-id');
          window.projectModal.open(pId, () => this.refreshDashboard());
        });
      });

    } catch (err) {
      grid.innerHTML = `<div class="error-state"><p>⚠️ Failed to load projects: ${err.message}</p></div>`;
    }
  }

  async renderChallengesGrid() {
    const grid = document.getElementById('challenges-grid-container');
    if (!grid) return;

    grid.innerHTML = `
      <div class="loading-state">
        <div class="spinner"></div>
        <p>Loading Checkpoint Troubleshooting Quizzes...</p>
      </div>
    `;

    try {
      const res = await fetch('/api/challenges', {
        headers: { 'Authorization': `Bearer ${this.token}` }
      });
      const data = await res.json();
      const challenges = data.challenges || [];

      grid.innerHTML = challenges.map(c => {
        const isLocked = !c.is_unlocked;
        const isCompleted = c.status === 'completed';

        return `
          <div class="challenge-card ${isLocked ? 'locked' : ''} ${isCompleted ? 'completed' : ''}">
            <div class="challenge-card-header">
              <span class="badge-pill checkpoint-pill">Checkpoint ${c.level_required}</span>
              <span class="badge-pill unlock-tier-pill">Unlocks Level ${c.level_target}</span>
              <span class="project-xp-reward">+${c.xp_reward} XP</span>
            </div>

            <div class="challenge-card-body">
              <h3 class="challenge-card-title">${c.title}</h3>
              <p class="challenge-card-desc">${c.description}</p>

              <div class="challenge-meta-row">
                <span class="stat-tag">🧩 ${c.questions_count} Diagnostic Scenarios</span>
                <span class="stat-tag">📐 ${c.category}</span>
                ${isCompleted ? `<span class="stat-tag score-badge">Score: ${c.score}%</span>` : ''}
              </div>
            </div>

            <div class="challenge-card-footer">
              ${isLocked ? `
                <div class="locked-footer">
                  <span>🔒 ${c.unlock_reason}</span>
                </div>
              ` : `
                <button class="btn ${isCompleted ? 'btn-secondary' : 'btn-primary'} btn-block btn-open-challenge" data-id="${c.id}">
                  ${isCompleted ? '🔄 Retake Checkpoint Challenge' : '🎯 Start Checkpoint Quiz'}
                </button>
              `}
            </div>
          </div>
        `;
      }).join('');

      grid.querySelectorAll('.btn-open-challenge').forEach(btn => {
        btn.addEventListener('click', (e) => {
          const chId = e.currentTarget.getAttribute('data-id');
          window.challengeModal.open(chId);
        });
      });

    } catch (err) {
      grid.innerHTML = `<div class="error-state"><p>⚠️ Failed to load challenges: ${err.message}</p></div>`;
    }
  }

  async renderBadgesGrid() {
    const grid = document.getElementById('badges-grid-container');
    if (!grid) return;

    try {
      const res = await fetch('/api/badges', {
        headers: { 'Authorization': `Bearer ${this.token}` }
      });
      const data = await res.json();
      const badges = data.badges || [];

      grid.innerHTML = badges.map(b => {
        const isUnlocked = b.is_unlocked;
        return `
          <div class="badge-card ${isUnlocked ? 'unlocked' : 'locked'}">
            <div class="badge-icon-box">${b.icon}</div>
            <div class="badge-info">
              <div class="badge-category-tag">${b.category}</div>
              <h4 class="badge-title">${b.title}</h4>
              <p class="badge-description">${b.description}</p>
              <div class="badge-xp-bonus">+${b.xp_bonus} XP Bonus</div>
            </div>
            <div class="badge-status-marker">
              ${isUnlocked ? '✅ Unlocked' : '🔒 Locked'}
            </div>
          </div>
        `;
      }).join('');
    } catch (err) {
      grid.innerHTML = `<div class="error-state"><p>⚠️ Failed to load badges: ${err.message}</p></div>`;
    }
  }

  showRewardModal({ title, message, icon = '🎉', xp = 0, badges = [] }) {
    const modal = document.getElementById('reward-modal');
    if (!modal) return;

    modal.querySelector('#reward-modal-title').textContent = title;
    modal.querySelector('#reward-modal-message').textContent = message;
    modal.querySelector('#reward-modal-icon').textContent = icon;

    const xpBox = modal.querySelector('#reward-modal-xp-box');
    if (xp > 0) {
      xpBox.classList.remove('hidden');
      modal.querySelector('#reward-modal-xp-val').textContent = `+${xp} XP`;
    } else {
      xpBox.classList.add('hidden');
    }

    const badgesBox = modal.querySelector('#reward-modal-badges');
    if (badges && badges.length > 0) {
      badgesBox.classList.remove('hidden');
      badgesBox.innerHTML = `
        <div class="reward-new-badges">
          ${badges.map(b => `
            <div class="mini-badge-pill">
              <span>${b.icon}</span>
              <strong>${b.title}</strong>
            </div>
          `).join('')}
        </div>
      `;
    } else {
      badgesBox.classList.add('hidden');
    }

    modal.classList.remove('hidden');
  }
}

window.addEventListener('DOMContentLoaded', () => {
  window.MakerApp = new MakerAppController();
  window.MakerApp.init();
});

