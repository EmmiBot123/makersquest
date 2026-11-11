// MakerQuest Interactive Gamified Checkpoint Challenges & Quizzes (Level 4)
class ChallengeModal {
  constructor() {
    this.modalEl = document.getElementById('challenge-modal');
    this.currentChallenge = null;
    this.userAnswers = {};
    this.currentQuestionIndex = 0;
    this.isSubmitting = false;
    this.lastResult = null;
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

  async open(challengeId) {
    this.modalEl.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
    this.userAnswers = {};
    this.currentQuestionIndex = 0;
    this.lastResult = null;

    const bodyContainer = this.modalEl.querySelector('.modal-body-content');
    bodyContainer.innerHTML = `
      <div class="loading-state">
        <div class="spinner"></div>
        <p>Loading Checkpoint Troubleshooting Simulation...</p>
      </div>
    `;

    try {
      const res = await fetch(`/api/challenges/${challengeId}`, {
        headers: { 'Authorization': `Bearer ${window.MakerApp.getToken()}` }
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to load challenge');

      this.currentChallenge = data.challenge;
      this.render();
    } catch (err) {
      bodyContainer.innerHTML = `
        <div class="error-state">
          <p>⚠️ ${err.message}</p>
          <button class="btn btn-secondary btn-sm" onclick="window.challengeModal.close()">Close</button>
        </div>
      `;
    }
  }

  close() {
    this.modalEl.classList.add('hidden');
    document.body.style.overflow = 'auto';
  }

  render() {
    const c = this.currentChallenge;
    const headerContainer = this.modalEl.querySelector('.modal-header-content');

    headerContainer.innerHTML = `
      <div class="challenge-header">
        <div class="challenge-tags">
          <span class="badge-pill checkpoint-pill">🎯 Checkpoint Challenge</span>
          <span class="badge-pill unlock-tier-pill">Unlocks Level ${c.level_target}</span>
          <span class="badge-pill xp-pill">✨ +${c.xp_reward} XP Reward</span>
        </div>
        <h2 class="challenge-title">${c.title}</h2>
        <p class="challenge-desc">${c.description}</p>
      </div>
    `;

    const bodyContainer = this.modalEl.querySelector('.modal-body-content');

    // If we have submission results, display results view
    if (this.lastResult) {
      bodyContainer.innerHTML = this.renderResultsView(c, this.lastResult);
      this.attachResultsEvents();
      return;
    }

    // Active quiz question view
    const questions = c.questions || [];
    const q = questions[this.currentQuestionIndex];
    const total = questions.length;
    const isLast = this.currentQuestionIndex === total - 1;
    const selectedAnswer = this.userAnswers[q.id];

    bodyContainer.innerHTML = `
      <div class="quiz-runner-container">
        <!-- Progress Stepper -->
        <div class="quiz-stepper">
          <div class="quiz-step-info">
            <span>Troubleshooting Scenario ${this.currentQuestionIndex + 1} of ${total}</span>
            <span class="topic-tag">${q.topic || 'Engineering Fundamentals'}</span>
          </div>
          <div class="quiz-progress-track">
            <div class="quiz-progress-fill" style="width: ${((this.currentQuestionIndex + 1) / total) * 100}%"></div>
          </div>
        </div>

        <!-- Scenario Context Card -->
        <div class="scenario-card">
          <div class="scenario-badge">🔧 Workshop Problem Report:</div>
          <p class="scenario-text">${q.scenario}</p>
        </div>

        <!-- Question Prompt -->
        <div class="question-prompt-card">
          <h3 class="question-text">${q.question}</h3>

          <!-- Options List -->
          <div class="quiz-options-list">
            ${q.options.map((opt, optIdx) => {
              const isChecked = selectedAnswer === optIdx;
              return `
                <label class="quiz-option-card ${isChecked ? 'selected' : ''}" for="opt-${q.id}-${optIdx}">
                  <input
                    type="radio"
                    name="question-${q.id}"
                    id="opt-${q.id}-${optIdx}"
                    value="${optIdx}"
                    ${isChecked ? 'checked' : ''}
                  />
                  <div class="option-indicator">${String.fromCharCode(65 + optIdx)}</div>
                  <span class="option-label">${opt}</span>
                </label>
              `;
            }).join('')}
          </div>

          <!-- Hint Expander -->
          ${q.hint ? `
            <div class="hint-container">
              <button type="button" class="btn btn-xs btn-outline btn-toggle-hint" id="btn-toggle-hint">
                💡 Need a Maker Hint?
              </button>
              <div class="hint-box hidden" id="quiz-hint-box">
                <span class="hint-icon">🔍</span>
                <p>${q.hint}</p>
              </div>
            </div>
          ` : ''}
        </div>

        <!-- Bottom Navigation -->
        <div class="quiz-nav-row">
          <button class="btn btn-secondary ${this.currentQuestionIndex === 0 ? 'disabled' : ''}" id="btn-prev-q" ${this.currentQuestionIndex === 0 ? 'disabled' : ''}>
            ⬅️ Previous Scenario
          </button>

          ${isLast ? `
            <button class="btn btn-primary btn-glow" id="btn-submit-quiz">
              🚀 Submit Diagnostic & Complete Checkpoint!
            </button>
          ` : `
            <button class="btn btn-primary" id="btn-next-q">
              Next Scenario ➡️
            </button>
          `}
        </div>
      </div>
    `;

    this.attachQuizEvents(q, isLast);
  }

  attachQuizEvents(q, isLast) {
    // Option selection
    const radios = this.modalEl.querySelectorAll(`input[name="question-${q.id}"]`);
    radios.forEach(r => {
      r.addEventListener('change', (e) => {
        window.soundFx.playClick();
        this.userAnswers[q.id] = Number(e.target.value);
        this.modalEl.querySelectorAll('.quiz-option-card').forEach(card => card.classList.remove('selected'));
        e.target.closest('.quiz-option-card').classList.add('selected');
      });
    });

    // Hint toggle
    const hintBtn = this.modalEl.querySelector('#btn-toggle-hint');
    const hintBox = this.modalEl.querySelector('#quiz-hint-box');
    if (hintBtn && hintBox) {
      hintBtn.addEventListener('click', () => {
        window.soundFx.playClick();
        hintBox.classList.toggle('hidden');
      });
    }

    // Prev Button
    const prevBtn = this.modalEl.querySelector('#btn-prev-q');
    if (prevBtn && this.currentQuestionIndex > 0) {
      prevBtn.addEventListener('click', () => {
        window.soundFx.playClick();
        this.currentQuestionIndex--;
        this.render();
      });
    }

    // Next Button
    const nextBtn = this.modalEl.querySelector('#btn-next-q');
    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        if (this.userAnswers[q.id] === undefined) {
          alert('Please select an answer to continue!');
          return;
        }
        window.soundFx.playClick();
        this.currentQuestionIndex++;
        this.render();
      });
    }

    // Submit Button
    const submitBtn = this.modalEl.querySelector('#btn-submit-quiz');
    if (submitBtn) {
      submitBtn.addEventListener('click', async () => {
        if (this.userAnswers[q.id] === undefined) {
          alert('Please select an answer for the final scenario!');
          return;
        }

        submitBtn.disabled = true;
        submitBtn.innerHTML = 'Evaluating Answers...';

        try {
          const res = await fetch(`/api/challenges/${this.currentChallenge.id}/submit`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${window.MakerApp.getToken()}`
            },
            body: JSON.stringify({ answers: this.userAnswers })
          });
          const result = await res.json();
          if (!res.ok) throw new Error(result.error || 'Challenge evaluation failed');

          this.lastResult = result;

          if (result.passed) {
            window.soundFx.playFanfare();
            window.confetti.fire({ count: 140 });

            // Reward modal celebration
            let msg = `You scored ${result.score}% (${result.correct_count}/${result.total_questions}) and earned +${result.xp_gained} XP!`;
            if (result.leveled_up) {
              msg += ` 🔓 LEVEL UNLOCKED: You can now access Level ${result.new_level} DIY Projects!`;
            }
            window.MakerApp.showRewardModal({
              title: result.leveled_up ? `🌟 LEVEL ${result.new_level} UNLOCKED!` : '🎯 Checkpoint Cleared!',
              message: msg,
              icon: '🏆',
              xp: result.xp_gained,
              badges: result.new_badges || []
            });

            window.MakerApp.refreshDashboard();
          } else {
            window.soundFx.playClick();
          }

          this.render();
        } catch (err) {
          alert(err.message);
          submitBtn.disabled = false;
          submitBtn.innerHTML = 'Submit Diagnostic & Complete Checkpoint!';
        }
      });
    }
  }

  // Results & Educational Review View
  renderResultsView(c, result) {
    const passed = result.passed;
    return `
      <div class="quiz-results-container">
        <div class="results-score-hero ${passed ? 'passed' : 'failed'}">
          <div class="score-icon">${passed ? '🎉' : '🔄'}</div>
          <h3>${passed ? 'Checkpoint Mastered!' : 'Keep Tinkering! Review & Retry'}</h3>
          <div class="score-big-pill">
            Score: ${result.score}% (${result.correct_count} of ${result.total_questions} Correct)
          </div>
          <p class="score-summary-text">
            ${passed
              ? `Outstanding engineering analysis! You have earned +${result.xp_gained} XP and officially unlocked Level ${c.level_target}!`
              : `You need at least 65% to unlock Level ${c.level_target}. Review the maker explanations below and give it another try!`}
          </p>
        </div>

        <div class="review-questions-list">
          <h4>Detailed Engineering Diagnostic Review:</h4>
          ${result.question_results.map((qr, idx) => {
            return `
              <div class="review-item-card ${qr.is_correct ? 'correct' : 'incorrect'}">
                <div class="review-item-header">
                  <span class="review-status-tag">${qr.is_correct ? '✅ Correct' : '❌ Needs Revision'}</span>
                  <span class="review-topic">${qr.topic}</span>
                </div>
                <h5 class="review-q-title">Scenario ${idx + 1}: ${qr.question}</h5>
                <div class="review-choices">
                  <div class="choice-line user-choice">
                    <strong>Your Choice:</strong>
                    <span>${qr.options[qr.student_choice] || 'Not answered'}</span>
                  </div>
                  ${!qr.is_correct ? `
                    <div class="choice-line correct-choice">
                      <strong>Correct Solution:</strong>
                      <span>${qr.options[qr.correct_index]}</span>
                    </div>
                  ` : ''}
                </div>
                <div class="review-explanation">
                  <strong>💡 Engineering Explanation:</strong>
                  <p>${qr.explanation}</p>
                </div>
              </div>
            `;
          }).join('')}
        </div>

        <div class="results-bottom-actions">
          ${passed ? `
            <button class="btn btn-primary btn-lg" onclick="window.challengeModal.close()">
              🗺️ Continue on Level Map
            </button>
          ` : `
            <button class="btn btn-primary" id="btn-retry-quiz">
              🔄 Retry Checkpoint Challenge
            </button>
            <button class="btn btn-secondary" onclick="window.challengeModal.close()">
              Close
            </button>
          `}
        </div>
      </div>
    `;
  }

  attachResultsEvents() {
    const retryBtn = this.modalEl.querySelector('#btn-retry-quiz');
    if (retryBtn) {
      retryBtn.addEventListener('click', () => {
        window.soundFx.playClick();
        this.lastResult = null;
        this.userAnswers = {};
        this.currentQuestionIndex = 0;
        this.render();
      });
    }
  }
}

window.ChallengeModal = ChallengeModal;

