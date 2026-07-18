import React, { useState, useEffect, useRef } from 'react';
import './App.css';

const BACKEND_URL = 'http://localhost:5000';

const translations = {
  en: {
    workout: "Mental Math Workout",
    workoutDesc: "Sharpen your quantitative calculations with timed daily drills.",
    topicLabel: "Arithmetic Topic",
    levelLabel: "Difficulty Tier",
    durationLabel: "Session Duration",
    startBtn: "Start Practice Run",
    exitBtn: "Exit Drill",
    reportCard: "Drill Report Card",
    correctAnswers: "Correct Answers",
    accuracy: "Calculation Accuracy",
    pace: "Pace per Problem",
    apm: "Answers per Minute",
    review: "Detailed Problem Review",
    saveScore: "Save My Score (Sign In)",
    leaderboard: "Global Speed Leaderboard",
    leaderboardDesc: "Top speed calculations practitioners, ranked by highest Calculations per Minute (APM).",
    streak: "Daily Streak",
    streakDays: "Days",
    streakTip: "Practise 10 minutes daily to make calculations 100x faster.",
    practiceTab: "🎯 Practice Workout",
    leaderboardTab: "⚡ Global Speed Leaderboard",
    guestMode: "Guest Mode",
    offlinePractice: "Offline Practice",
    signIn: "Sign In",
    confirmExit: "Are you sure you want to exit the current math drill?"
  },
  hi: {
    workout: "मानसिक गणित कसरत",
    workoutDesc: "समयबद्ध दैनिक अभ्यासों के साथ अपनी गणनाओं को तेज करें।",
    topicLabel: "अंकगणित विषय",
    levelLabel: "कठिनाई स्तर",
    durationLabel: "सत्र की अवधि",
    startBtn: "अभ्यास शुरू करें",
    exitBtn: "बाहर निकलें",
    reportCard: "ड्रिल रिपोर्ट कार्ड",
    correctAnswers: "सही उत्तर",
    accuracy: "गणना सटीकता",
    pace: "प्रति प्रश्न गति",
    apm: "प्रति मिनट उत्तर",
    review: "विस्तृत प्रश्न समीक्षा",
    saveScore: "मेरा स्कोर सहेजें",
    leaderboard: "ग्लोबल स्पीड लीडरबोर्ड",
    leaderboardDesc: "शीर्ष गति गणना उपयोगकर्ता, प्रति मिनट उच्चतम गणना (APM) के आधार पर स्थान।",
    streak: "दैनिक निरंतरता",
    streakDays: "दिन",
    streakTip: "गणना को 100 गुना तेज करने के लिए प्रतिदिन 10 मिनट अभ्यास करें।",
    practiceTab: "🎯 अभ्यास कसरत",
    leaderboardTab: "⚡ ग्लोबल लीडरबोर्ड",
    guestMode: "अतिथि मोड",
    offlinePractice: "ऑफ़लाइन अभ्यास",
    signIn: "लॉग इन करें",
    confirmExit: "क्या आप वाकई वर्तमान गणित अभ्यास से बाहर निकलना चाहते हैं?"
  }
};

function App() {
  const [currentUser, setCurrentUser] = useState(null);
  
  // Settings & Localization States
  const [theme, setTheme] = useState(localStorage.getItem('calx_theme') || 'light');
  const [lang, setLang] = useState(localStorage.getItem('calx_lang') || 'en');

  // Navigation Tabs State
  const [activeTab, setActiveTab] = useState('drill'); // 'drill' or 'leaderboard'

  // Sidebar State
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // Auth Modal State
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);
  const [authMode, setAuthMode] = useState('login'); // 'login' or 'signup'
  const [loginUsername, setLoginUsername] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [signupFullName, setSignupFullName] = useState('');
  const [signupUsername, setSignupUsername] = useState('');
  const [signupPassword, setSignupPassword] = useState('');
  const [signupPhone, setSignupPhone] = useState('');
  const [signupEmail, setSignupEmail] = useState('');
  const [authError, setAuthError] = useState('');
  const [authLoading, setAuthLoading] = useState(false);

  // Configuration State
  const [selectedTopics, setSelectedTopics] = useState(['add']);
  const [selectedLevel, setSelectedLevel] = useState('easy');
  const [selectedDuration, setSelectedDuration] = useState(60); // 30, 60, 120, 300, 'custom'
  const [customDurationVal, setCustomDurationVal] = useState('90');

  // Math Game State
  const [isPlaying, setIsPlaying] = useState(false);
  const [recentScores, setRecentScores] = useState([]);
  const [isLoadingScores, setIsLoadingScores] = useState(false);
  const [streak, setStreak] = useState(0);
  const [averageScore, setAverageScore] = useState(0);

  // Leaderboard Data State
  const [leaderboardData, setLeaderboardData] = useState([]);
  const [isLoadingLeaderboard, setIsLoadingLeaderboard] = useState(false);

  // Detailed Analytics Drill Tracking
  const [sessionHistory, setSessionHistory] = useState([]); // [{ question, userAnswer, correctAnswer, isCorrect }]

  const [questionText, setQuestionText] = useState('');
  const [correctAnswer, setCorrectAnswer] = useState(0);
  const [userAnswer, setUserAnswer] = useState('');
  const [score, setScore] = useState(0);
  const [totalQuestions, setTotalQuestions] = useState(0);
  const [timeLeft, setTimeLeft] = useState(60);
  const [feedback, setFeedback] = useState({ text: '', type: '' });
  const [gameEnded, setGameEnded] = useState(false);

  const timerRef = useRef(null);
  const inputRef = useRef(null);

  // Sync data-theme attribute with theme state
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('calx_theme', theme);
  }, [theme]);

  // Sync localization state with localStorage
  useEffect(() => {
    localStorage.setItem('calx_lang', lang);
  }, [lang]);

  // Read session and URL search params on mount
  useEffect(() => {
    const savedUser = localStorage.getItem('calx_user');
    if (savedUser) {
      try {
        setCurrentUser(JSON.parse(savedUser));
      } catch (e) {
        localStorage.removeItem('calx_user');
      }
    }

    const params = new URLSearchParams(window.location.search);
    const mode = params.get('mode');
    if (!savedUser && (mode === 'signup' || mode === 'login')) {
      setAuthMode(mode);
      setIsAuthModalOpen(true);
    }
    
    // Clean query parameters from address bar to prevent recurring popups on reload
    if (mode) {
      window.history.replaceState({}, document.title, window.location.pathname);
    }

    // Google postMessage popup handler
    const handleGoogleMessage = async (event) => {
      if (event.data && event.data.type === 'GOOGLE_AUTH_SUCCESS') {
        const { email, name } = event.data.user;
        setAuthLoading(true);
        setAuthError('');
        try {
          const res = await fetch(`${BACKEND_URL}/api/auth/google`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, name })
          });
          const data = await res.json();
          if (data.success) {
            localStorage.setItem('calx_user', JSON.stringify(data.user));
            setCurrentUser(data.user);
            setIsAuthModalOpen(false);
          } else {
            setAuthError(data.error || "Google auth process failed.");
          }
        } catch (err) {
          setAuthError("Failed to reach server during Google Login.");
        } finally {
          setAuthLoading(false);
        }
      }
    };

    window.addEventListener('message', handleGoogleMessage);

    loadScores();
    loadLeaderboard();
    return () => {
      clearInterval(timerRef.current);
      window.removeEventListener('message', handleGoogleMessage);
    };
  }, []);

  const loadScores = async () => {
    setIsLoadingScores(true);
    try {
      const response = await fetch(`${BACKEND_URL}/api/scores`);
      const json = await response.json();
      if (json.success) {
        setRecentScores(json.data);
        if (json.data.length > 0) {
          const sum = json.data.reduce((acc, curr) => acc + curr.score, 0);
          setAverageScore(Math.round(sum / json.data.length));
        }
      }

      const statusRes = await fetch(`${BACKEND_URL}/api/status`);
      const statusJson = await statusRes.json();
      if (statusJson.success) {
        setStreak(statusJson.data.dailyActiveStreaks || 5);
      }
    } catch (e) {
      console.warn("DB offline.");
      setRecentScores([
        { id: 1, player: "guest_web_user", score: 18, totalQuestions: 20, timestamp: new Date().toISOString() },
        { id: 2, player: "guest_web_user", score: 14, totalQuestions: 15, timestamp: new Date(Date.now() - 3600000).toISOString() }
      ]);
    } finally {
      setIsLoadingScores(false);
    }
  };

  const loadLeaderboard = async () => {
    setIsLoadingLeaderboard(true);
    try {
      const response = await fetch(`${BACKEND_URL}/api/leaderboard`);
      const json = await response.json();
      if (json.success) {
        setLeaderboardData(json.data);
      }
    } catch (e) {
      console.warn("DB offline. Using mock speed leaderboard.");
      setLeaderboardData([
        { username: "speedmathpro", fullName: "Speed Math Pro", maxSpeed: 48 },
        { username: "quant_wizard", fullName: "Quant Wizard", maxSpeed: 42 },
        { username: "mathgenius", fullName: "Math Genius", maxSpeed: 38 },
        { username: "john.doe", fullName: "John Doe", maxSpeed: 32 }
      ]);
    } finally {
      setIsLoadingLeaderboard(false);
    }
  };

  // Auth operations
  const handleLogin = async (e) => {
    e.preventDefault();
    if (!loginUsername || !loginPassword) return;
    setAuthLoading(true);
    setAuthError('');

    try {
      const res = await fetch(`${BACKEND_URL}/api/auth/signin`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: loginUsername, password: loginPassword })
      });
      const data = await res.json();
      
      if (data.success) {
        localStorage.setItem('calx_user', JSON.stringify(data.user));
        setCurrentUser(data.user);
        setLoginUsername('');
        setLoginPassword('');
        setIsAuthModalOpen(false);
        loadScores();
        loadLeaderboard();
      } else {
        setAuthError(data.error || "Authentication failed.");
      }
    } catch (err) {
      setAuthError("Failed to reach server. Please ensure the backend database is active.");
    } finally {
      setAuthLoading(false);
    }
  };

  const handleSignup = async (e) => {
    e.preventDefault();
    if (!signupFullName || !signupUsername || !signupPassword || !signupPhone || !signupEmail) return;
    setAuthLoading(true);
    setAuthError('');

    try {
      const res = await fetch(`${BACKEND_URL}/api/auth/signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: signupFullName,
          username: signupUsername,
          password: signupPassword,
          phone_number: signupPhone,
          email: signupEmail
        })
      });
      const data = await res.json();

      if (data.success) {
        localStorage.setItem('calx_user', JSON.stringify(data.user));
        setCurrentUser(data.user);
        setSignupFullName('');
        setSignupUsername('');
        setSignupPassword('');
        setSignupPhone('');
        setSignupEmail('');
        setIsAuthModalOpen(false);
        loadScores();
        loadLeaderboard();
      } else {
        setAuthError(data.error || "Sign Up failed.");
      }
    } catch (err) {
      setAuthError("Failed to reach database server. Try again shortly.");
    } finally {
      setAuthLoading(false);
    }
  };

  const handleTopicToggle = (id) => {
    if (id === 'mix') {
      if (selectedTopics.length === 8) {
        setSelectedTopics(['add']);
      } else {
        setSelectedTopics(['add', 'sub', 'mul', 'div', 'sqrt', 'cbrt', 'sq', 'cb']);
      }
      return;
    }

    setSelectedTopics((prev) => {
      if (prev.includes(id)) {
        if (prev.length === 1) return prev;
        return prev.filter(t => t !== id);
      } else {
        return [...prev, id];
      }
    });
  };

  const handleLogout = () => {
    localStorage.removeItem('calx_user');
    setCurrentUser(null);
  };

  const handleGoogleLoginClick = () => {
    const width = 500;
    const height = 600;
    const left = window.screenX + (window.outerWidth - width) / 2;
    const top = window.screenY + (window.outerHeight - height) / 2;
    window.open(`${BACKEND_URL}/google-mock-auth.html`, 'google_auth', `width=${width},height=${height},left=${left},top=${top}`);
  };

  // Generate question
  const generateQuestion = () => {
    const topic = selectedTopics[Math.floor(Math.random() * selectedTopics.length)];

    let n1, n2, ans, text;
    const rand = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;

    switch (selectedLevel) {
      case 'easy':
        if (topic === 'add') {
          n1 = rand(1, 20); n2 = rand(1, 20); ans = n1 + n2; text = `${n1} + ${n2}`;
        } else if (topic === 'sub') {
          n1 = rand(5, 20); n2 = rand(1, n1 - 1); ans = n1 - n2; text = `${n1} - ${n2}`;
        } else if (topic === 'mul') {
          n1 = rand(1, 10); n2 = rand(1, 10); ans = n1 * n2; text = `${n1} × ${n2}`;
        } else if (topic === 'div') {
          n2 = rand(1, 10); ans = rand(1, 10); n1 = n2 * ans; text = `${n1} ÷ ${n2}`;
        } else if (topic === 'sqrt') {
          ans = rand(2, 10); n1 = ans * ans; text = `√${n1}`;
        } else if (topic === 'cbrt') {
          ans = rand(2, 5); n1 = ans * ans * ans; text = `∛${n1}`;
        } else if (topic === 'sq') {
          ans = rand(2, 12); n1 = ans; text = `${n1}²`;
        } else { // cb
          ans = rand(2, 5); n1 = ans; text = `${n1}³`;
        }
        break;

      case 'medium':
        if (topic === 'add') {
          n1 = rand(10, 100); n2 = rand(10, 100); ans = n1 + n2; text = `${n1} + ${n2}`;
        } else if (topic === 'sub') {
          n1 = rand(20, 100); n2 = rand(10, n1 - 5); ans = n1 - n2; text = `${n1} - ${n2}`;
        } else if (topic === 'mul') {
          n1 = rand(2, 15); n2 = rand(2, 15); ans = n1 * n2; text = `${n1} × ${n2}`;
        } else if (topic === 'div') {
          n2 = rand(2, 12); ans = rand(2, 12); n1 = n2 * ans; text = `${n1} ÷ ${n2}`;
        } else if (topic === 'sqrt') {
          ans = rand(11, 20); n1 = ans * ans; text = `√${n1}`;
        } else if (topic === 'cbrt') {
          ans = rand(6, 10); n1 = ans * ans * ans; text = `∛${n1}`;
        } else if (topic === 'sq') {
          ans = rand(13, 25); n1 = ans; text = `${n1}²`;
        } else { // cb
          ans = rand(6, 10); n1 = ans; text = `${n1}³`;
        }
        break;

      case 'hard':
        if (topic === 'add') {
          n1 = rand(100, 1000); n2 = rand(100, 1000); ans = n1 + n2; text = `${n1} + ${n2}`;
        } else if (topic === 'sub') {
          n1 = rand(200, 1000); n2 = rand(100, n1 - 10); ans = n1 - n2; text = `${n1} - ${n2}`;
        } else if (topic === 'mul') {
          n1 = rand(10, 40); n2 = rand(5, 20); ans = n1 * n2; text = `${n1} × ${n2}`;
        } else if (topic === 'div') {
          n2 = rand(5, 20); ans = rand(10, 40); n1 = n2 * ans; text = `${n1} ÷ ${n2}`;
        } else if (topic === 'sqrt') {
          ans = rand(21, 50); n1 = ans * ans; text = `√${n1}`;
        } else if (topic === 'cbrt') {
          ans = rand(11, 15); n1 = ans * ans * ans; text = `∛${n1}`;
        } else if (topic === 'sq') {
          ans = rand(26, 50); n1 = ans; text = `${n1}²`;
        } else { // cb
          ans = rand(11, 15); n1 = ans; text = `${n1}³`;
        }
        break;

      case 'advanced':
      default:
        if (topic === 'add') {
          n1 = rand(500, 5000); n2 = rand(500, 5000); ans = n1 + n2; text = `${n1} + ${n2}`;
        } else if (topic === 'sub') {
          n1 = rand(1000, 5000); n2 = rand(500, n1 - 100); ans = n1 - n2; text = `${n1} - ${n2}`;
        } else if (topic === 'mul') {
          n1 = rand(12, 100); n2 = rand(12, 100); ans = n1 * n2; text = `${n1} × ${n2}`;
        } else if (topic === 'div') {
          n2 = rand(12, 100); ans = rand(12, 100); n1 = n2 * ans; text = `${n1} ÷ ${n2}`;
        } else if (topic === 'sqrt') {
          ans = rand(51, 100); n1 = ans * ans; text = `√${n1}`;
        } else if (topic === 'cbrt') {
          ans = rand(16, 25); n1 = ans * ans * ans; text = `∛${n1}`;
        } else if (topic === 'sq') {
          ans = rand(51, 100); n1 = ans; text = `${n1}²`;
        } else { // cb
          ans = rand(16, 25); n1 = ans; text = `${n1}³`;
        }
        break;
    }

    setQuestionText(text);
    setCorrectAnswer(ans);
    setUserAnswer('');
    setFeedback({ text: '', type: '' });
    
    setTimeout(() => {
      if (inputRef.current) inputRef.current.focus();
    }, 50);
  };

  const startGame = () => {
    let duration = selectedDuration === 'custom' ? parseInt(customDurationVal, 10) : selectedDuration;
    if (isNaN(duration) || duration <= 0) duration = 60;

    setIsPlaying(true);
    setScore(0);
    setTotalQuestions(0);
    setTimeLeft(duration);
    setGameEnded(false);
    setSessionHistory([]); // Clear prior run logs
    
    setTimeout(generateQuestion, 50);

    timerRef.current = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(timerRef.current);
          endGame();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  };

  // Auto-checking onChange handler
  const handleInputChange = (e) => {
    const val = e.target.value;
    setUserAnswer(val);

    const valNum = parseInt(val, 10);
    if (isNaN(valNum)) return;

    if (valNum === correctAnswer) {
      setScore(prev => prev + 1);
      setTotalQuestions(prev => prev + 1);
      setFeedback({ text: lang === 'en' ? 'Correct!' : 'सही उत्तर!', type: 'correct' });
      
      // Append correct question details to history log
      setSessionHistory(prev => [...prev, {
        question: questionText,
        userAnswer: val,
        correctAnswer: correctAnswer,
        isCorrect: true
      }]);

      setTimeout(generateQuestion, 250);
    }
  };

  // Form submit handles manual skips or incorrect answers
  const handleSubmit = (e) => {
    e.preventDefault();
    const ansNum = parseInt(userAnswer, 10);
    const isCorrect = (!isNaN(ansNum) && ansNum === correctAnswer);

    setTotalQuestions(prev => prev + 1);
    if (isCorrect) {
      setScore(prev => prev + 1);
      setFeedback({ text: lang === 'en' ? 'Correct!' : 'सही उत्तर!', type: 'correct' });
    } else {
      setFeedback({ text: lang === 'en' ? `Incorrect. It was ${correctAnswer}` : `गलत उत्तर। सही उत्तर ${correctAnswer} था।`, type: 'incorrect' });
    }

    setSessionHistory(prev => [...prev, {
      question: questionText,
      userAnswer: userAnswer,
      correctAnswer: correctAnswer,
      isCorrect: isCorrect
    }]);

    setTimeout(generateQuestion, 600);
  };

  const handleExitDrill = () => {
    const msg = translations[lang].confirmExit || "Are you sure you want to exit the current math drill?";
    if (window.confirm(msg)) {
      clearInterval(timerRef.current);
      setIsPlaying(false);
      setGameEnded(false);
      setUserAnswer('');
      setFeedback({ text: '', type: '' });
    }
  };

  const endGame = async () => {
    setGameEnded(true);
    setIsPlaying(false);
    
    try {
      const topicLabels = { add: "Add", sub: "Sub", mul: "Mul", div: "Div", sqrt: "Sqrt", cbrt: "Cbrt", sq: "Square", cb: "Cube" };
      const levelLabels = { easy: "Easy", medium: "Medium", hard: "Hard", advanced: "Adv" };
      const activeDuration = selectedDuration === 'custom' ? parseInt(customDurationVal, 10) || 60 : selectedDuration;
      const activeTopicLabels = selectedTopics.map(t => topicLabels[t] || t).join(", ");

      await fetch(`${BACKEND_URL}/api/scores`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          username: currentUser ? currentUser.username : "guest_web_user",
          score: score,
          totalQuestions: totalQuestions,
          duration: activeDuration,
          player: `${currentUser ? 'Web' : 'Guest Web'} (${activeTopicLabels} - ${levelLabels[selectedLevel]})`
        })
      });
    } catch (e) {
      console.warn("Backend offline.");
    }
    loadScores();
    loadLeaderboard();
  };

  // Detailed Analytics Metrics
  const activeDuration = selectedDuration === 'custom' ? parseInt(customDurationVal, 10) || 60 : selectedDuration;
  const accuracy = totalQuestions > 0 ? Math.round((score / totalQuestions) * 100) : 0;
  const speedPace = totalQuestions > 0 ? (activeDuration / totalQuestions).toFixed(1) : '0';
  const answersPerMin = activeDuration > 0 ? Math.round((score / activeDuration) * 60) : 0;

  return (
    <div className="app-layout">
      {/* Collapsible Sidebar */}
      <aside className={`app-sidebar ${isSidebarOpen ? '' : 'collapsed'}`}>
        <div className="sidebar-header">
          <div className="sidebar-brand">
            <svg className="logo-icon-svg" viewBox="0 0 32 32" width="28" height="28" style={{flexShrink:0}}>
              <circle cx="16" cy="16" r="16" fill="#0f172a" />
              <path d="M19.5 9.5a7 7 0 1 0 0 13h2.5a9.5 9.5 0 1 1 0-19h-2.5z" fill="#ffffff" />
              <path d="M19 14.5h5.5v3H19z" fill="#06b6d4" />
              <path d="M20.25 12v8l3.5-4-3.5-4z" fill="#06b6d4" />
            </svg>
            <span className="logo-text">Calx</span>
          </div>
          <button 
            className="collapse-btn" 
            onClick={() => setIsSidebarOpen(false)} 
            title="Collapse Sidebar"
          >
            ←
          </button>
        </div>
        
        {currentUser ? (
          <div className="user-profile-box">
            <div className="user-avatar">
              {currentUser.full_name ? currentUser.full_name[0].toUpperCase() : currentUser.username[0].toUpperCase()}
            </div>
            <div className="user-info">
              <span className="user-name">{currentUser.full_name || currentUser.username}</span>
              <span className="user-email">@{currentUser.username}</span>
            </div>
            <button onClick={handleLogout} className="logout-btn" title={lang === 'en' ? 'Sign Out' : 'लॉग आउट'}>
              {lang === 'en' ? 'Sign Out' : 'लॉग आउट'}
            </button>
          </div>
        ) : (
          <div className="user-profile-box guest-profile">
            <div className="guest-header-row">
              <div className="user-avatar guest">G</div>
              <div className="user-info">
                <span className="user-name">{translations[lang].guestMode}</span>
                <span className="user-email">{translations[lang].offlinePractice}</span>
              </div>
            </div>
            <button 
              onClick={() => { setAuthMode('login'); setAuthError(''); setIsAuthModalOpen(true); }} 
              className="login-trigger-btn"
            >
              {translations[lang].signIn}
            </button>
          </div>
        )}

        <div className="streak-widget">
          <div className="streak-label">{translations[lang].streak}</div>
          <div className="streak-value">{streak} {translations[lang].streakDays}</div>
          <p className="streak-tip">{translations[lang].streakTip}</p>
        </div>

        {/* Local Settings Toggle Rows */}
        <div className="sidebar-settings" style={{ marginTop: 'auto', borderTop: '1px solid var(--border-color)', paddingTop: '1.2rem' }}>
          <div className="settings-row" style={{ display: 'flex', gap: '8px' }}>
            <button 
              onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')} 
              className="settings-btn"
              style={{ flex: 1, padding: '8px', border: '1px solid var(--border-color)', borderRadius: '6px', fontSize: '0.75rem', fontWeight: 600, background: 'var(--bg-primary)', color: 'var(--text-primary)', cursor: 'pointer', outline: 'none' }}
              title={theme === 'light' ? 'Switch to Dark Mode' : 'Switch to Light Mode'}
            >
              {theme === 'light' ? '🌙 Dark' : '☀️ Light'}
            </button>
            <button 
              onClick={() => setLang(lang === 'en' ? 'hi' : 'en')} 
              className="settings-btn"
              style={{ flex: 1, padding: '8px', border: '1px solid var(--border-color)', borderRadius: '6px', fontSize: '0.75rem', fontWeight: 600, background: 'var(--bg-primary)', color: 'var(--text-primary)', cursor: 'pointer', outline: 'none' }}
              title={lang === 'en' ? 'हिंदी में बदलें' : 'Switch to English'}
            >
              🌐 {lang === 'en' ? 'HI' : 'EN'}
            </button>
          </div>
        </div>
      </aside>

      {/* Main Panel */}
      <main className="app-main">
        {/* Top Tab Bar Switching between Practice and Global Leaderboards */}
        <div className="main-nav-tabs">
          {!isSidebarOpen && (
            <button 
              className="menu-expand-btn-inline" 
              onClick={() => setIsSidebarOpen(true)}
              title="Expand Sidebar"
            >
              ☰ Menu
            </button>
          )}
          <button 
            onClick={() => setActiveTab('drill')} 
            className={`tab-link ${activeTab === 'drill' ? 'active' : ''}`}
          >
            {translations[lang].practiceTab}
          </button>
          <button 
            onClick={() => { setActiveTab('leaderboard'); loadLeaderboard(); }} 
            className={`tab-link ${activeTab === 'leaderboard' ? 'active' : ''}`}
          >
            {translations[lang].leaderboardTab}
          </button>
        </div>

        {activeTab === 'drill' ? (
          /* Practice Workout Console View */
          <section className="practice-console">
            {!isPlaying && !gameEnded && (
              <div className="config-view">
                <h2>{translations[lang].workout}</h2>
                <p className="config-desc">{translations[lang].workoutDesc}</p>
                
                <div className="select-group">
                  <label>{translations[lang].topicLabel}</label>
                  <div className="option-grid">
                    {[
                      { id: 'add', label: lang === 'en' ? 'Addition (+)' : 'जोड़ (+)' },
                      { id: 'sub', label: lang === 'en' ? 'Subtraction (-)' : 'घटाव (-)' },
                      { id: 'mul', label: lang === 'en' ? 'Multiplication (×)' : 'गुणा (×)' },
                      { id: 'div', label: lang === 'en' ? 'Division (÷)' : 'भाग (÷)' },
                      { id: 'sqrt', label: lang === 'en' ? 'Square Root (√)' : 'वर्गमूल (√)' },
                      { id: 'cbrt', label: lang === 'en' ? 'Cube Root (∛)' : 'घनमूल (∛)' },
                      { id: 'sq', label: lang === 'en' ? 'Squares (x²)' : 'वर्ग (x²)' },
                      { id: 'cb', label: lang === 'en' ? 'Cubes (x³)' : 'घन (x³)' },
                      { id: 'mix', label: lang === 'en' ? 'Select All' : 'सभी चुनें' }
                    ].map(item => (
                      <button 
                        key={item.id} 
                        onClick={() => handleTopicToggle(item.id)}
                        className={`option-btn ${selectedTopics.includes(item.id) || (item.id === 'mix' && selectedTopics.length === 8) ? 'active' : ''}`}
                      >
                        {item.label}
                      </button>
                    ))}
                  </div>
                </div>

                <div className="select-group">
                  <label>{translations[lang].levelLabel}</label>
                  <div className="option-grid option-grid-four">
                    {[
                      { id: 'easy', label: lang === 'en' ? 'Easy' : 'आसान' },
                      { id: 'medium', label: lang === 'en' ? 'Medium' : 'मध्यम' },
                      { id: 'hard', label: lang === 'en' ? 'Hard' : 'कठिन' },
                      { id: 'advanced', label: lang === 'en' ? 'Advanced' : 'उन्नत' }
                    ].map(item => (
                      <button 
                        key={item.id} 
                        onClick={() => setSelectedLevel(item.id)}
                        className={`option-btn btn-lvl-${item.id} ${selectedLevel === item.id ? 'active' : ''}`}
                      >
                        {item.label}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Timer Duration Selector */}
                <div className="select-group">
                  <label>{translations[lang].durationLabel}</label>
                  <div className="option-grid" style={{ gridTemplateColumns: 'repeat(5, 1fr)' }}>
                    {[
                      { id: 30, label: '30s' },
                      { id: 60, label: '1m' },
                      { id: 120, label: '2m' },
                      { id: 300, label: '5m' },
                      { id: 'custom', label: lang === 'en' ? 'Custom' : 'कस्टम' }
                    ].map(item => (
                      <button 
                        key={item.id} 
                        onClick={() => setSelectedDuration(item.id)}
                        className={`option-btn ${selectedDuration === item.id ? 'active' : ''}`}
                      >
                        {item.label}
                      </button>
                    ))}
                  </div>
                  
                  {selectedDuration === 'custom' && (
                    <div className="custom-duration-input-box" style={{ marginTop: '0.8rem', display: 'flex', flexDirection: 'column', gap: '0.4rem', textAlign: 'left' }}>
                      <label style={{ fontSize: '0.72rem', fontWeight: 700, textTransform: 'uppercase', color: 'var(--text-muted)' }}>
                        {lang === 'en' ? 'Enter Custom Duration (seconds)' : 'कस्टम अवधि दर्ज करें (सेकंड)'}
                      </label>
                      <input 
                        type="number" 
                        min="5" 
                        max="3600" 
                        value={customDurationVal} 
                        onChange={(e) => setCustomDurationVal(e.target.value)} 
                        placeholder="e.g. 45, 90, 600"
                        style={{ padding: '0.6rem 1rem', border: '1px solid var(--border-color)', borderRadius: '6px', fontSize: '0.9rem', outline: 'none', width: '100%', fontFamily: 'var(--font-stack)', backgroundColor: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                      />
                    </div>
                  )}
                </div>

                <button onClick={startGame} className="btn btn-dark btn-lg start-practice-btn">
                  {translations[lang].startBtn}
                </button>
              </div>
            )}

            {isPlaying && (
              <div className="play-view">
                <div className="game-header">
                  <span className="game-timer">{lang === 'en' ? 'Time Left' : 'समय बचा'}: <strong>{timeLeft}</strong>s</span>
                  <span className="game-score">{lang === 'en' ? 'Score' : 'स्कोर'}: <strong>{score}</strong> / {totalQuestions}</span>
                </div>
                <div className="game-body">
                  <div className="math-problem-display">
                    {questionText}
                  </div>
                  <form onSubmit={handleSubmit} className="math-answer-form">
                    <input
                      ref={inputRef}
                      type="number"
                      value={userAnswer}
                      onChange={handleInputChange}
                      placeholder={lang === 'en' ? "Enter answer" : "उत्तर दर्ज करें"}
                      autoComplete="off"
                    />
                  </form>
                  <div className={`game-feedback ${feedback.type}`}>
                    {feedback.text}
                  </div>
                  <div className="game-footer" style={{ marginTop: '2rem' }}>
                    <button onClick={handleExitDrill} className="btn btn-light exit-drill-btn w-100">
                      {translations[lang].exitBtn}
                    </button>
                  </div>
                </div>
              </div>
            )}

            {gameEnded && (
              <div className="results-view analytics-container">
                <h2>{translations[lang].reportCard}</h2>
                
                <div className="analytics-metrics-grid">
                  <div className="metric-card">
                    <div className="metric-val">{score}</div>
                    <div className="metric-lbl">{translations[lang].correctAnswers}</div>
                    <div className="metric-sub">{lang === 'en' ? `Out of ${totalQuestions} questions` : `${totalQuestions} प्रश्नों में से`}</div>
                  </div>
                  <div className="metric-card">
                    <div className="metric-val">{accuracy}%</div>
                    <div className="metric-lbl">{translations[lang].accuracy}</div>
                    <div className="metric-sub">{lang === 'en' ? 'Aim for >90% accuracy' : '90% से अधिक का लक्ष्य रखें'}</div>
                  </div>
                  <div className="metric-card">
                    <div className="metric-val">{speedPace}s</div>
                    <div className="metric-lbl">{translations[lang].pace}</div>
                    <div className="metric-sub">{lang === 'en' ? 'Average solving speed' : 'औसत हल करने की गति'}</div>
                  </div>
                  <div className="metric-card">
                    <div className="metric-val">{answersPerMin}/m</div>
                    <div className="metric-lbl">{translations[lang].apm}</div>
                    <div className="metric-sub">{lang === 'en' ? 'Calculated solving rate' : 'प्रति मिनट गणना दर'}</div>
                  </div>
                </div>

                <div className="analytics-details">
                  <h3>{translations[lang].review}</h3>
                  <div className="analytics-scroll-box">
                    <table className="analytics-table">
                      <thead>
                        <tr>
                          <th>{lang === 'en' ? 'Calculation' : 'गणना'}</th>
                          <th>{lang === 'en' ? 'Your Input' : 'आपका उत्तर'}</th>
                          <th>{lang === 'en' ? 'Correct Value' : 'सही मूल्य'}</th>
                          <th>{lang === 'en' ? 'Status' : 'स्थिति'}</th>
                        </tr>
                      </thead>
                      <tbody>
                        {sessionHistory.map((item, idx) => (
                          <tr key={idx} className={item.isCorrect ? 'row-correct' : 'row-incorrect'}>
                            <td className="math-problem-cell">{item.question}</td>
                            <td className="math-answer-cell font-monospace">{item.userAnswer || '(skipped)'}</td>
                            <td className="math-answer-cell font-monospace font-bold">{item.correctAnswer}</td>
                            <td className="math-status-cell">
                              {item.isCorrect ? (lang === 'en' ? '✅ Correct' : '✅ सही') : (lang === 'en' ? '❌ Wrong' : '❌ गलत')}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>

                <div className="results-actions">
                  {!currentUser && (
                    <button 
                      onClick={() => { setAuthMode('signup'); setAuthError(''); setIsAuthModalOpen(true); }} 
                      className="btn btn-dark"
                      style={{ backgroundColor: '#10b981', color: '#ffffff', borderColor: '#10b981' }}
                    >
                      {translations[lang].saveScore}
                    </button>
                  )}
                  <button onClick={startGame} className="btn btn-dark">
                    {lang === 'en' ? 'Practice Again' : 'फिर से अभ्यास करें'}
                  </button>
                  <button onClick={() => setGameEnded(false)} className="btn btn-light">
                    {lang === 'en' ? 'Back to Menu' : 'मुख्य मेनू'}
                  </button>
                </div>
              </div>
            )}
          </section>
        ) : (
          /* Global Speed Leaderboard View */
          <section className="leaderboard-section">
            <div className="leaderboard-header">
              <h2>{translations[lang].leaderboard}</h2>
              <p>{translations[lang].leaderboardDesc}</p>
            </div>

            <div className="leaderboard-card">
              {isLoadingLeaderboard ? (
                <div className="text-center text-muted" style={{ padding: '3rem' }}>
                  {lang === 'en' ? 'Fetching rankings from Neon DB...' : 'डेटाबेस से रैंकिंग लोड हो रही है...'}
                </div>
              ) : leaderboardData.length === 0 ? (
                <div className="text-center text-muted" style={{ padding: '3rem' }}>
                  {lang === 'en' ? 'No records logged yet. Start a practice drill!' : 'अभी तक कोई रिकॉर्ड नहीं है। अभ्यास शुरू करें!'}
                </div>
              ) : (
                <div className="leaderboard-list">
                  {leaderboardData.map((item, index) => {
                    const isTopThree = index < 3;
                    const rankLabels = ["🥇", "🥈", "🥉"];
                    return (
                      <div key={index} className={`leaderboard-item rank-${index + 1}`}>
                        <div className="item-rank">
                          {isTopThree ? rankLabels[index] : `#${index + 1}`}
                        </div>
                        <div className="item-user-info">
                          <div className="item-avatar-mini">
                            {item.fullName[0].toUpperCase()}
                          </div>
                          <div className="item-names">
                            <span className="item-fullname">{item.fullName}</span>
                            <span className="item-username">@{item.username}</span>
                          </div>
                        </div>
                        <div className="item-speed">
                          <span className="speed-val">{item.maxSpeed}</span>
                          <span className="speed-lbl">APM</span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </section>
        )}
      </main>

      {/* Optional Auth Modal Overlay */}
      {isAuthModalOpen && (
        <div className="modal-overlay">
          <div className="auth-card relative">
            <button onClick={() => setIsAuthModalOpen(false)} className="close-modal-x" title="Close Panel">✕</button>
            <div className="auth-brand">
              <svg className="logo-icon-svg" viewBox="0 0 32 32" width="28" height="28" style={{flexShrink:0, display:'inline-block', verticalAlign:'middle', marginRight:'8px'}}>
                <circle cx="16" cy="16" r="16" fill="#0f172a" />
                <path d="M19.5 9.5a7 7 0 1 0 0 13h2.5a9.5 9.5 0 1 1 0-19h-2.5z" fill="#ffffff" />
                <path d="M19 14.5h5.5v3H19z" fill="#06b6d4" />
                <path d="M20.25 12v8l3.5-4-3.5-4z" fill="#06b6d4" />
              </svg>
              <span className="logo-text" style={{verticalAlign:'middle'}}>Calx</span>
            </div>
            <h2>{authMode === 'login' ? 'Welcome Back' : 'Create Account'}</h2>
            <p className="auth-subtitle">Sync your scores and streak analytics to your persistent database profile.</p>
            
            {authError && <div className="auth-error-box">{authError}</div>}
            
            {authMode === 'login' ? (
              <form onSubmit={handleLogin} className="auth-form">
                <div className="form-group">
                  <label>Username</label>
                  <input 
                    type="text" 
                    value={loginUsername}
                    onChange={(e) => setLoginUsername(e.target.value)}
                    placeholder="Enter your unique username"
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Password</label>
                  <input 
                    type="password" 
                    value={loginPassword}
                    onChange={(e) => setLoginPassword(e.target.value)}
                    placeholder="Enter your password"
                    required
                  />
                </div>
                <button type="submit" disabled={authLoading} className="btn btn-dark w-100">
                  {authLoading ? 'Signing In...' : 'Sign In'}
                </button>
                <div className="google-divider">
                  <span>or</span>
                </div>
                <button 
                  type="button" 
                  onClick={handleGoogleLoginClick} 
                  className="btn btn-light btn-google w-100"
                >
                  <svg className="google-icon" viewBox="0 0 24 24">
                    <path fill="#EA4335" d="M12 5.04c1.66 0 3.2.57 4.38 1.69l3.27-3.27C17.67 1.48 14.97 1 12 1 7.35 1 3.39 3.65 1.5 7.5l3.86 3C6.27 7.74 8.89 5.04 12 5.04z"/>
                    <path fill="#4285F4" d="M23.49 12.27c0-.81-.07-1.59-.2-2.36H12v4.51h6.46c-.28 1.48-1.12 2.73-2.38 3.58l3.7 2.87c2.16-2 3.71-4.94 3.71-8.6z"/>
                    <path fill="#FBBC05" d="M5.36 14.5c-.24-.72-.38-1.49-.38-2.3s.14-1.58.38-2.3L1.5 6.9C.54 8.82 0 10.96 0 13.2s.54 4.38 1.5 6.3l3.86-3z"/>
                    <path fill="#34A853" d="M12 23c3.24 0 5.97-1.07 7.96-2.91l-3.7-2.87c-1.03.69-2.34 1.1-4.26 1.1-3.11 0-5.73-2.7-6.64-5.46L1.5 15.82C3.39 19.65 7.35 23 12 23z"/>
                  </svg>
                  Continue with Google
                </button>
                <p className="auth-switch">
                  New to Calx? <button type="button" onClick={() => { setAuthMode('signup'); setAuthError(''); }}>Create Account</button>
                </p>
              </form>
            ) : (
              <form onSubmit={handleSignup} className="auth-form">
                <div className="form-group">
                  <label>Full Name</label>
                  <input 
                    type="text" 
                    value={signupFullName}
                    onChange={(e) => setSignupFullName(e.target.value)}
                    placeholder="e.g. John Doe"
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Unique Username</label>
                  <input 
                    type="text" 
                    value={signupUsername}
                    onChange={(e) => setSignupUsername(e.target.value)}
                    placeholder="e.g. mathpro99"
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Password</label>
                  <input 
                    type="password" 
                    value={signupPassword}
                    onChange={(e) => setSignupPassword(e.target.value)}
                    placeholder="Create a password"
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Phone Number</label>
                  <input 
                    type="tel" 
                    value={signupPhone}
                    onChange={(e) => setSignupPhone(e.target.value)}
                    placeholder="e.g. 9876543210"
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Email Address</label>
                  <input 
                    type="email" 
                    value={signupEmail}
                    onChange={(e) => setSignupEmail(e.target.value)}
                    placeholder="e.g. user@domain.com"
                    required
                  />
                </div>
                <button type="submit" disabled={authLoading} className="btn btn-dark w-100">
                  {authLoading ? 'Registering...' : 'Sign Up'}
                </button>
                <div className="google-divider">
                  <span>or</span>
                </div>
                <button 
                  type="button" 
                  onClick={handleGoogleLoginClick} 
                  className="btn btn-light btn-google w-100"
                >
                  <svg className="google-icon" viewBox="0 0 24 24">
                    <path fill="#EA4335" d="M12 5.04c1.66 0 3.2.57 4.38 1.69l3.27-3.27C17.67 1.48 14.97 1 12 1 7.35 1 3.39 3.65 1.5 7.5l3.86 3C6.27 7.74 8.89 5.04 12 5.04z"/>
                    <path fill="#4285F4" d="M23.49 12.27c0-.81-.07-1.59-.2-2.36H12v4.51h6.46c-.28 1.48-1.12 2.73-2.38 3.58l3.7 2.87c2.16-2 3.71-4.94 3.71-8.6z"/>
                    <path fill="#FBBC05" d="M5.36 14.5c-.24-.72-.38-1.49-.38-2.3s.14-1.58.38-2.3L1.5 6.9C.54 8.82 0 10.96 0 13.2s.54 4.38 1.5 6.3l3.86-3z"/>
                    <path fill="#34A853" d="M12 23c3.24 0 5.97-1.07 7.96-2.91l-3.7-2.87c-1.03.69-2.34 1.1-4.26 1.1-3.11 0-5.73-2.7-6.64-5.46L1.5 15.82C3.39 19.65 7.35 23 12 23z"/>
                  </svg>
                  Continue with Google
                </button>
                <p className="auth-switch">
                  Have an account? <button type="button" onClick={() => { setAuthMode('login'); setAuthError(''); }}>Sign In</button>
                </p>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
