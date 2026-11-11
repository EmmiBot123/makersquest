// MakerQuest Visual Level Progression Map (Level 2)
class LevelMapRenderer {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
  }

  render(levelNodes, currentUser, onSelectLevel, onOpenChallenge) {
    if (!this.container) return;

    const levelThemeIcons = {
      1: '📦',
      2: '⚙️',
      3: '💡',
      4: '🤖',
      5: '🌻'
    };

    let html = `
      <div class="level-map-wrapper">
        <div class="level-map-header">
          <div class="level-map-title-group">
            <span class="badge-pill theme-badge">🗺️ Journey to Master Maker</span>
            <h2 class="level-map-title">Interactive Level Progression Map</h2>
            <p class="level-map-subtitle">Master each engineering tier and conquer Checkpoint Challenges to unlock higher realms!</p>
          </div>
          <div class="level-map-legend">
            <span class="legend-item"><span class="legend-dot completed"></span> Completed</span>
            <span class="legend-item"><span class="legend-dot active"></span> Current Realm</span>
            <span class="legend-item"><span class="legend-dot locked"></span> Locked</span>
          </div>
        </div>

        <div class="level-map-canvas-container">
          <!-- Winding Path Visualizer -->
          <svg class="level-map-svg-path" viewBox="0 0 1000 320" preserveAspectRatio="none">
            <defs>
              <linearGradient id="pathGradientUnlocked" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" stop-color="#10B981" />
                <stop offset="50%" stop-color="#4F46E5" />
                <stop offset="100%" stop-color="#F59E0B" />
              </linearGradient>
              <linearGradient id="pathGradientLocked" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" stop-color="#CBD5E1" />
                <stop offset="100%" stop-color="#94A3B8" />
              </linearGradient>
            </defs>
            <!-- Wavy Bezier connecting paths between the 5 nodes -->
            <path class="map-path-bg" d="M 100 160 C 220 70, 280 250, 325 160 C 420 70, 480 250, 550 160 C 640 70, 700 250, 775 160 C 850 80, 890 220, 920 160" />
            <path class="map-path-fg" d="M 100 160 C 220 70, 280 250, 325 160 C 420 70, 480 250, 550 160 C 640 70, 700 250, 775 160 C 850 80, 890 220, 920 160" />
          </svg>

          <!-- Floating Island Nodes -->
          <div class="level-nodes-grid">
    `;

    levelNodes.forEach((node, idx) => {
      const isLocked = !node.is_unlocked;
      const isCompleted = node.is_completed;
      const isCurrent = node.is_current;
      const icon = levelThemeIcons[node.level] || '✨';

      let statusClass = 'locked';
      let statusBadge = '<span class="status-chip locked"><i class="icon-lock">🔒</i> Locked</span>';

      if (isCompleted) {
        statusClass = 'completed';
        statusBadge = '<span class="status-chip completed">🏆 Mastered</span>';
      } else if (!isLocked) {
        statusClass = isCurrent ? 'current' : 'unlocked';
        statusBadge = isCurrent
          ? '<span class="status-chip active">📍 Current Level</span>'
          : '<span class="status-chip unlocked">🔓 In Progress</span>';
      }

      html += `
        <div class="level-node-card ${statusClass}" data-level="${node.level}">
          <div class="level-node-beacon">
            <div class="node-ring">
              <span class="node-icon">${icon}</span>
              ${isCompleted ? '<span class="node-star">⭐</span>' : ''}
              ${isLocked ? '<span class="node-lock-badge">🔒</span>' : ''}
            </div>
            <div class="node-number-tag">Level ${node.level}</div>
          </div>

          <div class="level-node-content">
            <div class="node-header">
              ${statusBadge}
              <span class="xp-range-tag">${node.minXp} - ${node.maxXp} XP</span>
            </div>
            <h3 class="node-title">${node.title}</h3>
            <p class="node-theme">${node.theme}</p>

            <div class="node-metrics">
              <div class="node-metric-bar">
                <div class="metric-info">
                  <span>DIY Projects</span>
                  <strong>${node.projects_completed} / ${node.projects_total}</strong>
                </div>
                <div class="mini-progress-track">
                  <div class="mini-progress-fill" style="width: ${node.projects_total > 0 ? (node.projects_completed / node.projects_total) * 100 : 0}%"></div>
                </div>
              </div>

              ${node.challenge_id ? `
                <div class="checkpoint-indicator ${node.challenge_completed ? 'cleared' : 'pending'}">
                  <span class="chk-icon">${node.challenge_completed ? '✅' : '🎯'}</span>
                  <div class="chk-text">
                    <span class="chk-label">Checkpoint Challenge:</span>
                    <strong class="chk-title">${node.challenge_title || 'Level Checkpoint'}</strong>
                  </div>
                </div>
              ` : ''}
            </div>

            ${isLocked ? `
              <div class="lock-explainer">
                <p>🔒 ${node.unlock_reason}</p>
              </div>
            ` : `
              <div class="node-actions">
                <button class="btn btn-sm btn-outline btn-filter-level" data-level="${node.level}">
                  🛠️ View Projects (${node.projects_completed}/${node.projects_total})
                </button>
                ${node.challenge_id && !node.challenge_completed ? `
                  <button class="btn btn-sm btn-primary btn-launch-challenge" data-challenge-id="${node.challenge_id}">
                    🎯 Take Checkpoint Quiz
                  </button>
                ` : ''}
              </div>
            `}
          </div>
        </div>
      `;
    });

    html += `
          </div>
        </div>
      </div>
    `;

    this.container.innerHTML = html;

    // Attach click events
    this.container.querySelectorAll('.btn-filter-level').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const lvl = Number(e.currentTarget.getAttribute('data-level'));
        if (typeof onSelectLevel === 'function') onSelectLevel(lvl);
      });
    });

    this.container.querySelectorAll('.btn-launch-challenge').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const chId = e.currentTarget.getAttribute('data-challenge-id');
        if (typeof onOpenChallenge === 'function') onOpenChallenge(chId);
      });
    });
  }
}

window.LevelMapRenderer = LevelMapRenderer;

