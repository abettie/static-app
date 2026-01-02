// 九九練習アプリ
class KukuApp {
    constructor() {
        this.questionEl = document.getElementById('question');
        this.answerEl = document.getElementById('answer');
        this.isShowingAnswer = false;

        // 初期化
        this.init();
    }

    init() {
        // 最初の問題を生成
        this.generateNewQuestion();

        // クリック・タップイベントを設定
        document.addEventListener('click', () => this.handleClick());
        document.addEventListener('touchstart', (e) => {
            e.preventDefault();
            this.handleClick();
        });
    }

    // ランダムな九九の問題を生成
    generateNewQuestion() {
        const num1 = Math.floor(Math.random() * 9) + 1; // 1-9
        const num2 = Math.floor(Math.random() * 9) + 1; // 1-9
        const answer = num1 * num2;

        this.currentQuestion = `${num1}×${num2}=`;
        this.currentAnswer = String(answer);

        // 問題を表示
        this.showQuestion();
    }

    // 問題を表示
    showQuestion() {
        this.questionEl.textContent = this.currentQuestion;
        this.questionEl.classList.remove('hidden');
        this.answerEl.classList.add('hidden');
        this.isShowingAnswer = false;
    }

    // 答えを表示
    showAnswer() {
        this.answerEl.textContent = this.currentAnswer;
        this.answerEl.classList.remove('hidden');
        this.questionEl.classList.add('hidden');
        this.isShowingAnswer = true;

        // 0.5秒後に次の問題を表示
        setTimeout(() => {
            this.generateNewQuestion();
        }, 500);
    }

    // クリック・タップ処理
    handleClick() {
        if (!this.isShowingAnswer) {
            this.showAnswer();
        }
    }
}

// アプリを起動
document.addEventListener('DOMContentLoaded', () => {
    new KukuApp();
});
