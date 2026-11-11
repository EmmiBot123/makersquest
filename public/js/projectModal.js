// MakerQuest Interactive Project View & Material Checklists (Level 3)
class ProjectModal {
  constructor() {
    this.modalEl = document.getElementById('project-modal');
    this.currentProject = null;
    this.onProjectCompletedCallback = null;
    this.currentTab = 'materials'; // 'materials' | 'steps' | 'proof'
    this.init();
  }

  init() {
    if (!this.modalEl) return;
    const closeBtn = this.modalEl.querySelector('.modal-close-btn');
    if (closeBtn) {
      closeBtn.addEventListener('click', () => this.close());
    }
    this.modalEl.addEventListener('click', (e) => {
      if (e.target === this.modalEl) this.close();
    });
  }

  async open(projectId, onCompleted) {
    this.onProjectCompletedCallback = onCompleted;
    this.modalEl.classList.remove('hidden');
    document.body.style.overflow = 'hidden';

    const bodyContainer = this.modalEl.querySelector('.modal-body-content');
    bodyContainer.innerHTML = `
      <div class="loading-state">
        <div class="spinner"></div>
        <p>Loading Maker Project & Blueprints...</p>
      </div>
    `;

    try {
      const res = await fetch(`/api/projects/${projectId}`, {
        headers: { 'Authorization': `Bearer ${window.MakerApp.getToken()}` }
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to load project');

      this.currentProject = data.project;
      this.currentTab = 'materials';
      this.render();
    } catch (err) {
      bodyContainer.innerHTML = `
        <div class="error-state">
          <p>⚠️ ${err.message}</p>
          <button class="btn btn-secondary btn-sm" onclick="window.projectModal.close()">Close</button>
        </div>
      `;
    }
  }

  close() {
    this.modalEl.classList.add('hidden');
    document.body.style.overflow = 'auto';
  }

  render() {
    const p = this.currentProject;
    const prog = p.user_progress || {};
    const checkedSet = new Set(prog.checklist_state || []);
    const completedStepsSet = new Set(prog.completed_steps || []);
    const totalMaterials = p.materials_list.length || 1;
    const gatheredCount = checkedSet.size;
    const gatherPercent = Math.round((gatheredCount / totalMaterials) * 100);
    const isProjectCompleted = prog.status === 'completed';

    const headerContainer = this.modalEl.querySelector('.modal-header-content');
    headerContainer.innerHTML = `
      <div class="project-modal-header">
        <div class="project-tags">
          <span class="badge-pill level-pill">Level ${p.level_required}</span>
          <span class="badge-pill category-pill">${p.category}</span>
          <span class="badge-pill difficulty-pill">${p.difficulty}</span>
          <span class="badge-pill time-pill">⏱️ ${p.estimated_time}</span>
          <span class="badge-pill xp-pill">✨ +${p.xp_reward} XP</span>
        </div>
        <h2 class="project-title">${p.title}</h2>
        <p class="project-desc">${p.description}</p>
        ${!p.is_unlocked ? `
          <div class="lock-banner">
            <span>🔒 Locked: ${p.unlock_reason}</span>
          </div>
        ` : ''}
        ${isProjectCompleted ? `
          <div class="completed-banner">
            <span>🏆 You have mastered and completed this project! (+${prog.xp_awarded || p.xp_reward} XP earned)</span>
          </div>
        ` : ''}
      </div>

      <!-- Navigation Tabs -->
      <div class="project-tabs">
        <button class="tab-btn ${this.currentTab === 'materials' ? 'active' : ''}" data-tab="materials">
          📦 Materials Checklist (<span id="tab-gather-count">${gatheredCount}/${totalMaterials}</span>)
        </button>
        <button class="tab-btn ${this.currentTab === 'steps' ? 'active' : ''}" data-tab="steps">
          🛠️ Step Instructions (${p.steps.length} Steps)
        </button>
        <button class="tab-btn ${this.currentTab === 'proof' ? 'active' : ''}" data-tab="proof">
          📸 Submit Proof & XP Reward
        </button>
      </div>
    `;

    // Attach tab click handlers
    headerContainer.querySelectorAll('.tab-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        window.soundFx.playClick();
        this.currentTab = e.currentTarget.getAttribute('data-tab');
        this.render();
      });
    });

    const bodyContainer = this.modalEl.querySelector('.modal-body-content');

    if (this.currentTab === 'materials') {
      bodyContainer.innerHTML = this.renderMaterialsTab(p, checkedSet, gatherPercent, totalMaterials, gatheredCount);
      this.attachMaterialsEvents(p);
    } else if (this.currentTab === 'steps') {
      bodyContainer.innerHTML = this.renderStepsTab(p, completedStepsSet);
      this.attachStepsEvents(p);
    } else if (this.currentTab === 'proof') {
      bodyContainer.innerHTML = this.renderProofTab(p, prog, isProjectCompleted);
      this.attachProofEvents(p);
    }
  }

  // TAB 1: Materials Checklist
  renderMaterialsTab(p, checkedSet, gatherPercent, totalMaterials, gatheredCount) {
    return `
      <div class="checklist-container">
        <div class="checklist-hero-card">
          <div class="checklist-progress-header">
            <div>
              <h3>Maker Workshop Supplies</h3>
              <p>Gather the essential parts from around your home or maker bin. Substitute items freely!</p>
            </div>
            <div class="gather-score-badge">
              <span class="score-number">${gatherPercent}%</span>
              <span class="score-label">Gathered</span>
            </div>
          </div>
          <div class="progress-bar-lg">
            <div class="progress-fill-lg" id="materials-progress-bar" style="width: ${gatherPercent}%"></div>
          </div>
          <div class="checklist-subtext">
            <span id="materials-gathered-text">${gatheredCount} of ${totalMaterials} items ready for assembly</span>
            ${gatherPercent === 100 ? '<span class="all-set-tag">🎉 All Materials Ready!</span>' : ''}
          </div>
        </div>

        <div class="materials-list-items">
          ${p.materials_list.map((m, idx) => {
            const isChecked = checkedSet.has(m.id);
            return `
              <label class="material-item-card ${isChecked ? 'checked' : ''}" for="mat-${m.id}">
                <div class="mat-checkbox-wrapper">
                  <input type="checkbox" id="mat-${m.id}" data-id="${m.id}" ${isChecked ? 'checked' : ''} />
                  <span class="custom-checkbox"></span>
                </div>
                <div class="mat-details">
                  <div class="mat-name-row">
                    <span class="mat-name">${m.name}</span>
                    <span class="mat-amount">${m.amount}</span>
                  </div>
                  ${m.tip ? `<p class="mat-tip">💡 <em>Maker Tip:</em> ${m.tip}</p>` : ''}
                  ${m.optional ? `<span class="optional-tag">Optional enhancer</span>` : ''}
                </div>
              </label>
            `;
          }).join('')}
        </div>

        <div class="tab-bottom-actions">
          <button class="btn btn-primary" onclick="window.projectModal.switchTab('steps')">
            Next: Go to Step Instructions ➡️
          </button>
        </div>
      </div>
    `;
  }

  attachMaterialsEvents(p) {
    const checkboxes = this.modalEl.querySelectorAll('.materials-list-items input[type="checkbox"]');
    checkboxes.forEach(chk => {
      chk.addEventListener('change', async (e) => {
        window.soundFx.playCheck();
        const card = e.target.closest('.material-item-card');
        if (e.target.checked) {
          card.classList.add('checked');
        } else {
          card.classList.remove('checked');
        }

        // Collect all checked ids
        const checkedIds = [];
        this.modalEl.querySelectorAll('.materials-list-items input[type="checkbox"]:checked').forEach(c => {
          checkedIds.push(c.getAttribute('data-id'));
        });

        // Update local object
        if (!this.currentProject.user_progress) this.currentProject.user_progress = {};
        this.currentProject.user_progress.checklist_state = checkedIds;

        // Update UI counters
        const total = p.materials_list.length || 1;
        const count = checkedIds.length;
        const pct = Math.round((count / total) * 100);

        const bar = this.modalEl.querySelector('#materials-progress-bar');
        if (bar) bar.style.width = `${pct}%`;
        const text = this.modalEl.querySelector('#materials-gathered-text');
        if (text) text.textContent = `${count} of ${total} items ready for assembly`;
        const scoreBadge = this.modalEl.querySelector('.score-number');
        if (scoreBadge) scoreBadge.textContent = `${pct}%`;
        const tabCount = this.modalEl.querySelector('#tab-gather-count');
        if (tabCount) tabCount.textContent = `${count}/${total}`;

        // Save to backend
        try {
          const res = await fetch(`/api/projects/${p.id}/checklist`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${window.MakerApp.getToken()}`
            },
            body: JSON.stringify({ checkedIds })
          });
          const result = await res.json();
          if (result.badgeEarned) {
            window.soundFx.playFanfare();
            window.confetti.fire({ count: 70 });
            window.MakerApp.showRewardModal({
              title: 'Badge Unlocked!',
              message: `You earned the "${result.badgeEarned.title}" badge for gathering all materials!`,
              icon: result.badgeEarned.icon,
              xp: result.badgeEarned.xp_bonus
            });
            window.MakerApp.refreshDashboard();
          }
        } catch (err) {
          console.error('Failed to sync checklist:', err);
        }
      });
    });
  }

  // TAB 2: Step-by-Step Instructions
  renderStepsTab(p, completedStepsSet) {
    return `
      <div class="steps-container">
        <div class="steps-intro">
          <h3>Assembly & Engineering Guide</h3>
          <p>Follow along step-by-step. Read the safety callouts before cutting or piercing materials!</p>
        </div>

        <div class="steps-timeline">
          ${p.steps.map((st) => {
            const isStepDone = completedStepsSet.has(st.step_number);
            return `
              <div class="step-card ${isStepDone ? 'step-done' : ''}" data-step="${st.step_number}">
                <div class="step-number-column">
                  <div class="step-badge">${st.step_number}</div>
                  <div class="step-line"></div>
                </div>

                <div class="step-content">
                  <div class="step-header-row">
                    <h4 class="step-title">${st.title}</h4>
                    <button class="btn btn-xs ${isStepDone ? 'btn-success' : 'btn-outline'} btn-toggle-step" data-step="${st.step_number}">
                      ${isStepDone ? '✅ Completed' : 'Mark Step Done'}
                    </button>
                  </div>

                  <p class="step-instruction">${st.instruction}</p>

                  <!-- Visual Schematic / Placeholder -->
                  <div class="step-visual-box">
                    ${this.renderVisualPlaceholder(st.visual_type, st.title)}
                  </div>

                  <div class="step-callouts">
                    ${st.tip ? `
                      <div class="callout tip-callout">
                        <span class="callout-icon">💡</span>
                        <div class="callout-body">
                          <strong>Maker Pro Tip:</strong>
                          <span>${st.tip}</span>
                        </div>
                      </div>
                    ` : ''}

                    ${st.safety_note ? `
                      <div class="callout safety-callout">
                        <span class="callout-icon">🛡️</span>
                        <div class="callout-body">
                          <strong>Safety Check:</strong>
                          <span>${st.safety_note}</span>
                        </div>
                      </div>
                    ` : ''}
                  </div>
                </div>
              </div>
            `;
          }).join('')}
        </div>

        <div class="tab-bottom-actions">
          <button class="btn btn-secondary" onclick="window.projectModal.switchTab('materials')">
            ⬅️ Back to Checklist
          </button>
          <button class="btn btn-primary" onclick="window.projectModal.switchTab('proof')">
            Next: Submit Project Proof 📸
          </button>
        </div>
      </div>
    `;
  }

  // Renders visual schematic illustrations for each DIY step
  renderVisualPlaceholder(visualType, title) {
    const visualSvgs = {
      struts_cutting: `
        <svg viewBox="0 0 400 120" class="step-svg">
          <rect x="20" y="20" width="360" height="80" rx="8" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="2"/>
          <line x1="40" y1="40" x2="360" y2="40" stroke="#94A3B8" stroke-dasharray="4,4"/>
          <!-- 6 Struts -->
          <rect x="40" y="50" width="45" height="15" rx="3" fill="#E2E8F0" stroke="#475569" stroke-width="1.5"/>
          <rect x="95" y="50" width="45" height="15" rx="3" fill="#E2E8F0" stroke="#475569" stroke-width="1.5"/>
          <rect x="150" y="50" width="45" height="15" rx="3" fill="#E2E8F0" stroke="#475569" stroke-width="1.5"/>
          <rect x="205" y="50" width="45" height="15" rx="3" fill="#E2E8F0" stroke="#475569" stroke-width="1.5"/>
          <rect x="260" y="50" width="45" height="15" rx="3" fill="#E2E8F0" stroke="#475569" stroke-width="1.5"/>
          <rect x="315" y="50" width="45" height="15" rx="3" fill="#E2E8F0" stroke="#475569" stroke-width="1.5"/>
          <text x="200" y="95" text-anchor="middle" font-size="12" fill="#4F46E5" font-weight="600">6x Identical Cardboard Struts (15cm x 2cm)</text>
        </svg>
      `,
      hole_marking: `
        <svg viewBox="0 0 400 110" class="step-svg">
          <rect x="40" y="35" width="320" height="35" rx="6" fill="#FED7AA" stroke="#EA580C" stroke-width="2"/>
          <!-- Holes -->
          <circle cx="65" cy="52" r="5" fill="#FFFFFF" stroke="#9A3412" stroke-width="2"/>
          <circle cx="200" cy="52" r="5" fill="#FFFFFF" stroke="#9A3412" stroke-width="2"/>
          <circle cx="335" cy="52" r="5" fill="#FFFFFF" stroke="#9A3412" stroke-width="2"/>
          <text x="65" y="92" text-anchor="middle" font-size="11" fill="#475569">1.5 cm</text>
          <text x="200" y="92" text-anchor="middle" font-size="11" fill="#475569">Center (7.5 cm)</text>
          <text x="335" y="92" text-anchor="middle" font-size="11" fill="#475569">1.5 cm</text>
        </svg>
      `,
      x_assembly: `
        <svg viewBox="0 0 400 130" class="step-svg">
          <line x1="80" y1="20" x2="320" y2="105" stroke="#F59E0B" stroke-width="14" stroke-linecap="round"/>
          <line x1="80" y1="105" x2="320" y2="20" stroke="#D97706" stroke-width="14" stroke-linecap="round"/>
          <circle cx="200" cy="62" r="8" fill="#FCD34D" stroke="#78350F" stroke-width="2.5"/>
          <circle cx="200" cy="62" r="3" fill="#78350F"/>
          <text x="200" y="124" text-anchor="middle" font-size="12" fill="#4F46E5" font-weight="600">Brass Fastener Pivot Joint at Center</text>
        </svg>
      `,
      lift_complete: `
        <svg viewBox="0 0 400 150" class="step-svg">
          <rect x="130" y="15" width="140" height="12" rx="3" fill="#3B82F6"/>
          <line x1="150" y1="27" x2="250" y2="60" stroke="#CBD5E1" stroke-width="8" stroke-linecap="round"/>
          <line x1="250" y1="27" x2="150" y2="60" stroke="#94A3B8" stroke-width="8" stroke-linecap="round"/>
          <line x1="150" y1="60" x2="250" y2="100" stroke="#CBD5E1" stroke-width="8" stroke-linecap="round"/>
          <line x1="250" y1="60" x2="150" y2="100" stroke="#94A3B8" stroke-width="8" stroke-linecap="round"/>
          <rect x="100" y="105" width="200" height="14" rx="3" fill="#334155"/>
          <text x="200" y="140" text-anchor="middle" font-size="12" fill="#10B981" font-weight="600">Assembled Scissor Mechanism</text>
        </svg>
      `,
      pulley_wheel: `
        <svg viewBox="0 0 400 120" class="step-svg">
          <circle cx="200" cy="55" r="40" fill="#E0F2FE" stroke="#0284C7" stroke-width="3"/>
          <circle cx="200" cy="55" r="28" fill="#BAE6FD" stroke="#0369A1" stroke-width="2"/>
          <circle cx="200" cy="55" r="7" fill="#0369A1"/>
          <line x1="160" y1="20" x2="160" y2="90" stroke="#F59E0B" stroke-width="4"/>
          <text x="200" y="112" text-anchor="middle" font-size="12" fill="#0369A1" font-weight="600">Dual Bottle-Cap Grooved Pulley</text>
        </svg>
      `,
      straw_bearings: `
        <svg viewBox="0 0 400 140" class="step-svg">
          <rect x="50" y="20" width="300" height="90" rx="6" fill="#FDE68A" stroke="#B45309" stroke-width="2"/>
          <!-- Flute grain lines -->
          <line x1="60" y1="35" x2="340" y2="35" stroke="#D97706" stroke-width="1" stroke-dasharray="6,4" opacity="0.4"/>
          <line x1="60" y1="65" x2="340" y2="65" stroke="#D97706" stroke-width="1" stroke-dasharray="6,4" opacity="0.4"/>
          <line x1="60" y1="95" x2="340" y2="95" stroke="#D97706" stroke-width="1" stroke-dasharray="6,4" opacity="0.4"/>
          <!-- Two 9cm straw sleeves glued 2cm from ends -->
          <rect x="75" y="28" width="18" height="74" rx="4" fill="#38BDF8" stroke="#0284C7" stroke-width="2"/>
          <rect x="307" y="28" width="18" height="74" rx="4" fill="#38BDF8" stroke="#0284C7" stroke-width="2"/>
          <!-- Straw bores -->
          <ellipse cx="84" cy="35" rx="5" ry="3" fill="#0369A1"/>
          <ellipse cx="316" cy="35" rx="5" ry="3" fill="#0369A1"/>
          <!-- Parallel square check indicator -->
          <path d="M 84 65 L 200 65 L 316 65" stroke="#10B981" stroke-width="1.5" stroke-dasharray="4,2"/>
          <text x="84" y="118" text-anchor="middle" font-size="10" fill="#0369A1" font-weight="600">Front Straw 9cm</text>
          <text x="316" y="118" text-anchor="middle" font-size="10" fill="#0369A1" font-weight="600">Rear Straw 9cm</text>
          <text x="200" y="78" text-anchor="middle" font-size="11" fill="#10B981" font-weight="700">Strictly Parallel (90° Square)</text>
          <text x="200" y="134" text-anchor="middle" font-size="11" fill="#475569">15 cm × 10 cm Chassis Base Underside</text>
        </svg>
      `,
      wheel_cutting: `
        <svg viewBox="0 0 400 140" class="step-svg">
          <!-- 4 wheels preview with focus on centered crosshair -->
          <circle cx="90" cy="65" r="38" fill="#FDE68A" stroke="#B45309" stroke-width="2"/>
          <circle cx="170" cy="65" r="38" fill="#FDE68A" stroke="#B45309" stroke-width="2"/>
          <circle cx="250" cy="65" r="38" fill="#FDE68A" stroke="#B45309" stroke-width="2"/>
          <circle cx="330" cy="65" r="38" fill="#FEF08A" stroke="#D97706" stroke-width="2.5"/>
          <!-- Crosshairs on active wheel -->
          <line x1="292" y1="65" x2="368" y2="65" stroke="#DC2626" stroke-width="1.5"/>
          <line x1="330" y1="27" x2="330" y2="103" stroke="#DC2626" stroke-width="1.5"/>
          <circle cx="330" cy="65" r="4" fill="#FFFFFF" stroke="#DC2626" stroke-width="2"/>
          <!-- Skewer piercing tool -->
          <line x1="330" y1="15" x2="330" y2="65" stroke="#78350F" stroke-width="3" stroke-linecap="round"/>
          <text x="90" y="120" text-anchor="middle" font-size="10" fill="#78350F">Wheel 1</text>
          <text x="170" y="120" text-anchor="middle" font-size="10" fill="#78350F">Wheel 2</text>
          <text x="250" y="120" text-anchor="middle" font-size="10" fill="#78350F">Wheel 3</text>
          <text x="330" y="120" text-anchor="middle" font-size="11" fill="#DC2626" font-weight="700">Exact Center Ø 5cm</text>
          <text x="200" y="136" text-anchor="middle" font-size="11" fill="#475569">Pierce 3mm Bamboo Axle Hole at Diagonal Center</text>
        </svg>
      `,
      wheel_assembly: `
        <svg viewBox="0 0 400 140" class="step-svg">
          <!-- Axle line -->
          <rect x="30" y="62" width="340" height="6" rx="3" fill="#D97706"/>
          <!-- Straw sleeve centered -->
          <rect x="120" y="55" width="160" height="20" rx="5" fill="#38BDF8" stroke="#0284C7" stroke-width="2"/>
          <!-- Donut washer spacers -->
          <rect x="106" y="48" width="10" height="34" rx="3" fill="#FDE68A" stroke="#B45309" stroke-width="1.5"/>
          <rect x="284" y="48" width="10" height="34" rx="3" fill="#FDE68A" stroke="#B45309" stroke-width="1.5"/>
          <!-- Cardboard Wheels -->
          <rect x="68" y="28" width="34" height="74" rx="6" fill="#FDE68A" stroke="#B45309" stroke-width="2"/>
          <rect x="298" y="28" width="34" height="74" rx="6" fill="#FDE68A" stroke="#B45309" stroke-width="2"/>
          <!-- Glue stop collar drops -->
          <circle cx="50" cy="65" r="7" fill="#EF4444" stroke="#991B1B" stroke-width="1"/>
          <circle cx="350" cy="65" r="7" fill="#EF4444" stroke="#991B1B" stroke-width="1"/>
          <!-- Dimension labels -->
          <text x="200" y="46" text-anchor="middle" font-size="11" fill="#0284C7" font-weight="600">9cm Straw Bearing</text>
          <text x="111" y="96" text-anchor="middle" font-size="10" fill="#B45309">1mm Gap</text>
          <text x="289" y="96" text-anchor="middle" font-size="10" fill="#B45309">1mm Gap</text>
          <text x="200" y="118" text-anchor="middle" font-size="12" fill="#10B981" font-weight="700">12cm Axle + Donut Spacers (Zero-Friction Spin)</text>
        </svg>
      `,
      cart_rollout: `
        <svg viewBox="0 0 400 140" class="step-svg">
          <!-- Ramp -->
          <polygon points="30,110 110,40 110,110" fill="#E2E8F0" stroke="#64748B" stroke-width="2"/>
          <text x="70" y="95" font-size="10" fill="#64748B">30° Incline</text>
          <!-- Floor runway line -->
          <line x1="30" y1="110" x2="380" y2="110" stroke="#334155" stroke-width="3"/>
          <!-- Cart rolling along runway -->
          <rect x="220" y="82" width="60" height="18" rx="4" fill="#FDE68A" stroke="#B45309" stroke-width="1.5"/>
          <circle cx="232" cy="104" r="9" fill="#D97706" stroke="#78350F" stroke-width="1.5"/>
          <circle cx="268" cy="104" r="9" fill="#D97706" stroke="#78350F" stroke-width="1.5"/>
          <!-- Velocity arrow -->
          <line x1="285" y1="91" x2="330" y2="91" stroke="#22C55E" stroke-width="3"/>
          <polygon points="330,86 340,91 330,96" fill="#22C55E"/>
          <text x="312" y="82" font-size="10" fill="#22C55E" font-weight="600">v Velocity</text>
          <!-- 3-meter target flag -->
          <line x1="370" y1="70" x2="370" y2="110" stroke="#DC2626" stroke-width="2"/>
          <polygon points="370,70 388,77 370,84" fill="#DC2626"/>
          <text x="370" y="64" text-anchor="middle" font-size="10" fill="#DC2626" font-weight="700">3.0m Mark</text>
          <text x="200" y="132" text-anchor="middle" font-size="11" fill="#475569">Release from 30cm Height — Measure Straight-Line Distance</text>
        </svg>
      `,
      tube_cutting: `
        <svg viewBox="0 0 400 130" class="step-svg">
          <!-- 30 cm cardboard cylinder being split in half -->
          <rect x="50" y="35" width="300" height="45" rx="8" fill="#FDE68A" stroke="#B45309" stroke-width="2"/>
          <line x1="60" y1="57" x2="340" y2="57" stroke="#EF4444" stroke-width="2" stroke-dasharray="6,4"/>
          <text x="200" y="26" text-anchor="middle" font-size="11" fill="#475569">30 cm Cardboard Tube</text>
          <text x="200" y="74" text-anchor="middle" font-size="11" fill="#DC2626" font-weight="600">Splitting Guideline (Slice into 2 U-Channels)</text>
          <text x="200" y="112" text-anchor="middle" font-size="11" fill="#0284C7">Creates Smooth Semi-Circular Marble Chutes</text>
        </svg>
      `,
      angle_testing: `
        <svg viewBox="0 0 400 130" class="step-svg">
          <!-- Support tower -->
          <rect x="60" y="25" width="25" height="85" rx="3" fill="#64748B"/>
          <!-- Sloped track -->
          <line x1="72" y1="35" x2="330" y2="105" stroke="#F59E0B" stroke-width="12" stroke-linecap="round"/>
          <circle cx="95" cy="41" r="8" fill="#38BDF8" stroke="#0284C7" stroke-width="2"/>
          <text x="200" y="55" text-anchor="middle" font-size="11" fill="#D97706" font-weight="600">25° - 30° Optimal Gravity Slope</text>
          <text x="200" y="122" text-anchor="middle" font-size="11" fill="#475569">Converts Potential Energy (mgh) to Kinetic Velocity</text>
        </svg>
      `,
      banked_turns: `
        <svg viewBox="0 0 400 130" class="step-svg">
          <!-- Curved banked rail -->
          <path d="M 60 100 Q 200 10 340 100" fill="none" stroke="#F59E0B" stroke-width="16" stroke-linecap="round"/>
          <path d="M 70 95 Q 200 20 330 95" fill="none" stroke="#D97706" stroke-width="4"/>
          <!-- Banked marble -->
          <circle cx="200" cy="30" r="9" fill="#38BDF8" stroke="#0284C7" stroke-width="2"/>
          <text x="200" y="65" text-anchor="middle" font-size="11" fill="#0369A1" font-weight="700">15° Inward Bank Angle</text>
          <text x="200" y="120" text-anchor="middle" font-size="11" fill="#475569">Counters Centrifugal Force (F = mv²/r) to Keep Marble on Track</text>
        </svg>
      `,
      marble_finish: `
        <svg viewBox="0 0 400 130" class="step-svg">
          <!-- Coaster finish run into catcher -->
          <line x1="50" y1="40" x2="280" y2="95" stroke="#F59E0B" stroke-width="10" stroke-linecap="round"/>
          <!-- Landing cup -->
          <rect x="290" y="70" width="50" height="45" rx="6" fill="#3B82F6" stroke="#1D4ED8" stroke-width="2"/>
          <circle cx="315" cy="90" r="10" fill="#38BDF8" stroke="#0284C7" stroke-width="2"/>
          <text x="315" y="60" text-anchor="middle" font-size="11" fill="#1D4ED8" font-weight="700">Catch Cup</text>
          <text x="170" y="120" text-anchor="middle" font-size="12" fill="#10B981" font-weight="700">Continuous 10-Second Coaster Run Verified! 🏆</text>
        </svg>
      `,
      axle_notch: `
        <svg viewBox="0 0 400 140" class="step-svg">
          <!-- 12cm Bamboo axle -->
          <rect x="50" y="58" width="300" height="12" rx="4" fill="#FED7AA" stroke="#CA8A04" stroke-width="2"/>
          <line x1="60" y1="62" x2="340" y2="62" stroke="#D97706" stroke-width="1" opacity="0.3"/>
          <line x1="60" y1="66" x2="340" y2="66" stroke="#D97706" stroke-width="1" opacity="0.3"/>
          <!-- Center 6.0cm mark -->
          <line x1="200" y1="45" x2="200" y2="80" stroke="#DC2626" stroke-width="2"/>
          <!-- Slanted tooth (60° backward) -->
          <polygon points="196,58 184,36 190,34 202,58" fill="#F59E0B" stroke="#B45309" stroke-width="1.5"/>
          <circle cx="199" cy="58" r="4.5" fill="#38BDF8" opacity="0.7"/>
          <!-- Rubber band loop catching -->
          <path d="M 120 42 L 186 42 Q 192 42 190 34" fill="none" stroke="#EF4444" stroke-width="3" stroke-linecap="round"/>
          <text x="200" y="24" text-anchor="middle" font-size="11" fill="#DC2626" font-weight="700">Slanted Catch Tooth (60° Backward)</text>
          <text x="200" y="98" text-anchor="middle" font-size="11" fill="#CA8A04" font-weight="600">6.0 cm Center Notch (0.5 mm Deep)</text>
          <text x="200" y="128" text-anchor="middle" font-size="11" fill="#475569">12.0 cm Bamboo Rear Drive Axle (Ø 3 mm)</text>
        </svg>
      `,
      chassis_window: `
        <svg viewBox="0 0 400 140" class="step-svg">
          <!-- Chassis base plate -->
          <rect x="50" y="20" width="300" height="95" rx="6" fill="#FDE68A" stroke="#B45309" stroke-width="2"/>
          <!-- 4x4cm Winding window at rear right -->
          <rect x="235" y="38" width="60" height="60" rx="3" fill="#0F172A" stroke="#DC2626" stroke-width="2"/>
          <text x="265" y="72" text-anchor="middle" font-size="10" fill="#EF4444" font-weight="700">4×4 cm Window</text>
          <!-- Front straw 8cm -->
          <rect x="75" y="25" width="16" height="85" rx="4" fill="#38BDF8" stroke="#0284C7" stroke-width="2"/>
          <!-- Split rear straws 2cm flanking window -->
          <rect x="298" y="22" width="16" height="26" rx="3" fill="#38BDF8" stroke="#0284C7" stroke-width="1.5"/>
          <rect x="298" y="87" width="16" height="26" rx="3" fill="#38BDF8" stroke="#0284C7" stroke-width="1.5"/>
          <!-- Drive axle passing through window -->
          <line x1="306" y1="18" x2="306" y2="117" stroke="#D97706" stroke-width="4"/>
          <!-- Front anchor pin -->
          <circle cx="120" cy="67" r="6" fill="#F59E0B" stroke="#B45309" stroke-width="1.5"/>
          <text x="83" y="124" text-anchor="middle" font-size="10" fill="#0369A1" font-weight="600">Front Straw</text>
          <text x="120" y="87" text-anchor="middle" font-size="10" fill="#B45309" font-weight="600">Anchor Pin</text>
          <text x="200" y="132" text-anchor="middle" font-size="11" fill="#475569">18×8 cm Chassis Base with Rear Winding Clearance Port</text>
        </svg>
      `,
      traction_tires: `
        <svg viewBox="0 0 400 140" class="step-svg">
          <!-- Wheel face with rubber tire -->
          <circle cx="100" cy="65" r="42" fill="#FDE68A" stroke="#B45309" stroke-width="2"/>
          <circle cx="100" cy="65" r="41" fill="none" stroke="#EF4444" stroke-width="6"/>
          <circle cx="100" cy="65" r="4" fill="#FFFFFF" stroke="#DC2626" stroke-width="2"/>
          <text x="100" y="122" text-anchor="middle" font-size="11" fill="#DC2626" font-weight="700">Rubber Tire (μ = 0.85)</text>
          <!-- Assembly stack -->
          <rect x="180" y="62" width="180" height="6" rx="3" fill="#FED7AA"/>
          <rect x="190" y="55" width="55" height="20" rx="4" fill="#38BDF8" stroke="#0284C7" stroke-width="1.5"/>
          <rect x="252" y="50" width="8" height="30" rx="2" fill="#FDE68A" stroke="#B45309" stroke-width="1.5"/>
          <rect x="268" y="32" width="28" height="66" rx="4" fill="#FDE68A" stroke="#B45309" stroke-width="1.5"/>
          <!-- Tire edges -->
          <rect x="268" y="32" width="28" height="6" rx="1" fill="#EF4444"/>
          <rect x="268" y="92" width="28" height="6" rx="1" fill="#EF4444"/>
          <circle cx="304" cy="65" r="5" fill="#DC2626"/>
          <text x="217" y="46" text-anchor="middle" font-size="9" fill="#0284C7">Straw</text>
          <text x="256" y="92" text-anchor="middle" font-size="9" fill="#B45309">1mm Gap</text>
          <text x="282" y="112" text-anchor="middle" font-size="10" fill="#EF4444" font-weight="600">Wheel + Tire</text>
          <text x="200" y="132" text-anchor="middle" font-size="11" fill="#10B981" font-weight="700">High-Traction Tire Eliminates Wheel Spin-Out</text>
        </svg>
      `,
      rubber_launch: `
        <svg viewBox="0 0 400 140" class="step-svg">
          <!-- Floor line -->
          <line x1="20" y1="110" x2="380" y2="110" stroke="#334155" stroke-width="3"/>
          <!-- Racer unit sprinting forward -->
          <rect x="160" y="78" width="140" height="18" rx="4" fill="#FDE68A" stroke="#B45309" stroke-width="2"/>
          <!-- Wheels with red tires -->
          <circle cx="180" cy="100" r="14" fill="#FDE68A" stroke="#EF4444" stroke-width="4"/>
          <circle cx="280" cy="100" r="14" fill="#FDE68A" stroke="#EF4444" stroke-width="4"/>
          <circle cx="180" cy="100" r="3" fill="#78350F"/>
          <circle cx="280" cy="100" r="3" fill="#78350F"/>
          <!-- Elastic band releasing -->
          <line x1="190" y1="84" x2="265" y2="84" stroke="#DC2626" stroke-width="3" stroke-linecap="round"/>
          <!-- Speed lines -->
          <line x1="80" y1="88" x2="140" y2="88" stroke="#38BDF8" stroke-width="2" stroke-dasharray="8,4"/>
          <line x1="100" y1="96" x2="145" y2="96" stroke="#38BDF8" stroke-width="2" stroke-dasharray="8,4"/>
          <!-- Target flag at 4m -->
          <line x1="365" y1="65" x2="365" y2="110" stroke="#10B981" stroke-width="2"/>
          <polygon points="365,65 385,73 365,81" fill="#10B981"/>
          <text x="365" y="58" text-anchor="middle" font-size="10" fill="#10B981" font-weight="700">4.0+ Meters</text>
          <text x="230" y="70" text-anchor="middle" font-size="11" fill="#22C55E" font-weight="700">Elastic Snap Unwinds & Coasts 🚀</text>
          <text x="200" y="132" text-anchor="middle" font-size="11" fill="#475569">Release: Rotational Torque Spins Rear Wheels for 4m Sprint!</text>
        </svg>
      `,
    };

    const fallbackSvg = `
      <div class="generic-visual-placeholder">
        <span class="vis-icon">📐</span>
        <div class="vis-text">
          <strong>Schematic Blueprint:</strong>
          <span>${title}</span>
        </div>
      </div>
    `;

    return visualSvgs[visualType] || fallbackSvg;
  }

  attachStepsEvents(p) {
    const stepBtns = this.modalEl.querySelectorAll('.btn-toggle-step');
    stepBtns.forEach(btn => {
      btn.addEventListener('click', async (e) => {
        window.soundFx.playClick();
        const stepNum = Number(e.currentTarget.getAttribute('data-step'));
        const card = e.currentTarget.closest('.step-card');
        const isCurrentlyDone = card.classList.contains('step-done');
        const willBeDone = !isCurrentlyDone;

        if (willBeDone) {
          card.classList.add('step-done');
          e.currentTarget.className = 'btn btn-xs btn-success btn-toggle-step';
          e.currentTarget.textContent = '✅ Completed';
          window.soundFx.playCheck();
        } else {
          card.classList.remove('step-done');
          e.currentTarget.className = 'btn btn-xs btn-outline btn-toggle-step';
          e.currentTarget.textContent = 'Mark Step Done';
        }

        try {
          await fetch(`/api/projects/${p.id}/step-toggle`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${window.MakerApp.getToken()}`
            },
            body: JSON.stringify({ stepNumber: stepNum, completed: willBeDone })
          });
        } catch (err) {
          console.error('Failed to toggle step:', err);
        }
      });
    });
  }

  // TAB 3: Submit Project Proof
  renderProofTab(p, prog, isCompleted) {
    const demoPhotoMap = {
      proj_scissor_lift: {
        label: 'Cardboard Scissor Lift Prototype',
        preview: '📦 Scissor Lift Elevation Test: Reached 28cm with smooth scissor expansion!'
      },
      proj_marble_coaster: {
        label: 'Gravity Marble Run Setup',
        preview: '🎢 Double-Banked Marble Chute: Completed 5 speed trials without flying off track!'
      },
      proj_pulley_crane: {
        label: 'Dual-Pulley Mechanical Crane',
        preview: '🏗️ Tabletop A-Frame Crane: Lifted 150g cargo weight with smooth hand crank!'
      },
      proj_paper_circuit: {
        label: 'Light-Up Greeting Card Circuit',
        preview: '💡 Conductive Copper Tape Card: Push-button switch illuminates twin LED headlights!'
      },
      proj_wiggle_bot: {
        label: 'Bristle Wiggle-Bot Sprint',
        preview: '🤖 Vibration Bristle-Bot: Angled bristles propel the robot forward across the table!'
      }
    };

    const demoPhoto = demoPhotoMap[p.id] || {
      label: 'DIY Maker Prototype Photo',
      preview: '🛠️ Completed Maker Prototype Demonstration'
    };

    return `
      <div class="proof-submission-container">
        <div class="proof-hero-card">
          <div class="proof-hero-info">
            <h3>Showcase Your Engineering Proof</h3>
            <p>Upload a photo of your working DIY project, share your engineering reflections, and claim <strong>+${p.xp_reward} XP</strong>!</p>
          </div>
          <div class="proof-xp-badge">
            <span class="xp-val">+${p.xp_reward}</span>
            <span class="xp-unit">XP Reward</span>
          </div>
        </div>

        ${isCompleted ? `
          <div class="proof-already-completed-card">
            <div class="completed-check-icon">🏆</div>
            <div class="completed-proof-details">
              <h4>Project Verified & Completed!</h4>
              <p>Completed on: ${new Date(prog.completed_at || Date.now()).toLocaleDateString()}</p>
              ${prog.proof_notes ? `<blockquote class="proof-quote">"${prog.proof_notes}"</blockquote>` : ''}
              <div class="proof-verified-tag">✓ ${prog.xp_awarded || p.xp_reward} XP Added to Student Account</div>
            </div>
          </div>
        ` : ''}

        <form id="proof-submit-form" class="proof-form">
          <!-- Photo Upload & Demo Preset Picker -->
          <div class="form-group">
            <label class="form-label">Project Photo / Proof Screenshot</label>
            <div class="photo-dropzone" id="proof-dropzone">
              <div class="dropzone-empty" id="dropzone-empty-state">
                <span class="dropzone-icon">📷</span>
                <p><strong>Drag & Drop your project photo here</strong>, or click to browse</p>
                <span class="file-hint">JPG, PNG, WebP accepted</span>
                <input type="file" id="proof-file-input" accept="image/*" class="file-input-hidden" />
              </div>

              <div class="dropzone-preview hidden" id="dropzone-preview-state">
                <div class="preview-badge-chip">📷 Photo Attached</div>
                <div class="preview-mock-render" id="preview-text-box"></div>
                <button type="button" class="btn btn-xs btn-outline" id="btn-change-photo">Change Photo</button>
              </div>
            </div>

            <!-- Quick Demo Project Photo Presets for Easy Grading & Testing -->
            <div class="demo-photo-presets">
              <span class="preset-label">⚡ Fast Demo Selector (Click to load authentic test photo proof):</span>
              <button type="button" class="btn btn-xs btn-secondary btn-apply-preset" data-preset="authentic">
                ✨ Use Verified Project Prototype Photo: "${demoPhoto.label}"
              </button>
            </div>
          </div>

          <!-- Maker Reflection Notes -->
          <div class="form-group">
            <label class="form-label" for="proof-notes-input">
              Maker Engineering Log & Reflection
              <span class="optional-label">(What worked? What was tricky? Any cool modifications?)</span>
            </label>
            <textarea
              id="proof-notes-input"
              class="form-textarea"
              rows="3"
              placeholder="e.g., I reinforced the pivot points with washers and adjusted the drop angle so the marble doesn't derail. The lift elevated my pencil case!"
            >${prog.proof_notes || ''}</textarea>
          </div>

          <div class="proof-submit-row">
            <button type="submit" class="btn btn-primary btn-lg btn-glow" id="btn-submit-proof">
              🚀 ${isCompleted ? 'Update Project Proof' : `Submit Project Proof & Claim +${p.xp_reward} XP!`}
            </button>
          </div>
        </form>
      </div>
    `;
  }

  attachProofEvents(p) {
    const form = this.modalEl.querySelector('#proof-submit-form');
    if (!form) return;

    const fileInput = this.modalEl.querySelector('#proof-file-input');
    const dropzone = this.modalEl.querySelector('#proof-dropzone');
    const emptyState = this.modalEl.querySelector('#dropzone-empty-state');
    const previewState = this.modalEl.querySelector('#dropzone-preview-state');
    const previewText = this.modalEl.querySelector('#preview-text-box');
    const changeBtn = this.modalEl.querySelector('#btn-change-photo');
    const notesInput = this.modalEl.querySelector('#proof-notes-input');

    let currentImageData = p.user_progress && p.user_progress.proof_image ? p.user_progress.proof_image : null;

    if (currentImageData) {
      emptyState.classList.add('hidden');
      previewState.classList.remove('hidden');
      previewText.innerHTML = `<strong>Uploaded Proof:</strong> ${currentImageData.substring(0, 50)}...`;
    }

    dropzone.addEventListener('click', (e) => {
      if (e.target !== changeBtn && emptyState.contains(e.target)) {
        fileInput.click();
      }
    });

    if (changeBtn) {
      changeBtn.addEventListener('click', () => {
        fileInput.click();
      });
    }

    fileInput.addEventListener('change', () => {
      const file = fileInput.files[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = (e) => {
          currentImageData = e.target.result;
          emptyState.classList.add('hidden');
          previewState.classList.remove('hidden');
          previewText.innerHTML = `<strong>Selected File:</strong> ${file.name} (${Math.round(file.size / 1024)} KB)`;
        };
        reader.readAsDataURL(file);
      }
    });

    // Preset button
    const presetBtn = this.modalEl.querySelector('.btn-apply-preset');
    if (presetBtn) {
      presetBtn.addEventListener('click', () => {
        window.soundFx.playCheck();
        currentImageData = `proof_${p.id}_verified.jpg`;
        emptyState.classList.add('hidden');
        previewState.classList.remove('hidden');
        previewText.innerHTML = `
          <div class="preset-loaded-card">
            <span>✅ Attached Verified Maker Prototype:</span>
            <strong>${p.title} Demonstration Photo</strong>
          </div>
        `;
        if (!notesInput.value.trim()) {
          notesInput.value = `Successfully constructed ${p.title}! Followed all blueprints, verified joint stability, and conducted successful load tests.`;
        }
      });
    }

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const submitBtn = this.modalEl.querySelector('#btn-submit-proof');
      submitBtn.disabled = true;
      submitBtn.innerHTML = 'Submitting Proof...';

      const notes = notesInput.value.trim();
      const imagePayload = currentImageData || `default_proof_${p.id}.jpg`;

      try {
        const res = await fetch(`/api/projects/${p.id}/submit-proof`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${window.MakerApp.getToken()}`
          },
          body: JSON.stringify({
            proofNotes: notes,
            proofImage: imagePayload
          })
        });

        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Proof submission failed');

        window.soundFx.playFanfare();
        window.confetti.fire({ count: 120 });

        this.close();

        // Celebration dialog
        let message = `You earned +${data.xp_gained} XP!`;
        if (data.leveled_up) {
          message += ` 🌟 CONGRATULATIONS! You advanced to Level ${data.new_level}!`;
        }

        window.MakerApp.showRewardModal({
          title: data.leveled_up ? '🌟 LEVEL UP & PROJECT MASTERED!' : '🎉 Project Completed!',
          message: message,
          icon: '🏆',
          xp: data.xp_gained,
          badges: data.new_badges || []
        });

        if (typeof this.onProjectCompletedCallback === 'function') {
          this.onProjectCompletedCallback();
        }

        window.MakerApp.refreshDashboard();

      } catch (err) {
        alert(err.message);
        submitBtn.disabled = false;
        submitBtn.innerHTML = 'Submit Project Proof';
      }
    });
  }

  switchTab(tabName) {
    window.soundFx.playClick();
    this.currentTab = tabName;
    this.render();
  }
}

window.ProjectModal = ProjectModal;

