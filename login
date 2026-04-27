import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import api from "../utils/api";

const FLOATERS = Array.from({ length: 18 }, (_, i) => ({
  id: i,
  emoji: ["🎬","🍿","🎭","🎞️","⭐","🎥","🏆","💕","😄","😢","💥","😱"][Math.floor(Math.random() * 12)],
  left: Math.random() * 100,
  duration: 12 + Math.random() * 16,
  delay: Math.random() * 14,
  size: 16 + Math.random() * 14,
}));

export default function Login() {
  const [mode, setMode] = useState("login");
  const [form, setForm] = useState({ name: "", email: "", password: "" });
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const switchMode = (m) => {
    setMode(m); setError(""); setSuccess("");
    setForm({ name: "", email: "", password: "" });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(""); setSuccess("");
    if (mode === "signup" && !form.name.trim()) { setError("Please enter your name."); return; }
    if (form.password.length < 6) { setError("Password must be at least 6 characters."); return; }
    setLoading(true);
    try {
      const endpoint = mode === "login" ? "/login" : "/register";
      const payload = mode === "login"
        ? { email: form.email, password: form.password }
        : form;
      const res = await api.post(endpoint, payload);
      login(res.data.token, res.data.name);
      navigate("/");
    } catch (err) {
      setError(err.response?.data?.error || (mode === "login" ? "Invalid email or password." : "Registration failed."));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative min-h-screen flex items-center justify-center overflow-hidden px-4"
      style={{ background: "#0a0a0f", fontFamily: "'DM Sans', sans-serif" }}>

      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap');
        @keyframes floatUp { from{transform:translateY(100vh) rotate(0deg);opacity:.07} to{transform:translateY(-120px) rotate(20deg);opacity:0} }
        @keyframes cardIn { from{opacity:0;transform:translateY(24px) scale(.97)} to{opacity:1;transform:translateY(0) scale(1)} }
        @keyframes iconPop { from{transform:scale(.4);opacity:0} to{transform:scale(1);opacity:1} }
        @keyframes alertIn { from{opacity:0;transform:translateY(-6px)} to{opacity:1;transform:translateY(0)} }
        @keyframes filmroll { from{background-position:0 0} to{background-position:0 360px} }
        .cm-card { animation: cardIn .5s cubic-bezier(.22,1,.36,1) both; }
        .cm-icon { animation: iconPop .6s cubic-bezier(.34,1.56,.64,1) .2s both; display:block; }
        .cm-alert { animation: alertIn .25s ease both; }
        .cm-film { position:absolute;left:8px;right:8px;top:0;bottom:0;opacity:.5;
          background:repeating-linear-gradient(to bottom,transparent 0,transparent 14px,#1a1a26 14px,#1a1a26 22px);
          animation:filmroll 6s linear infinite; }
        .cm-input {
          width:100%; background:#1a1a26; border:1px solid rgba(255,255,255,.07);
          color:#f0eee8; border-radius:11px; padding:13px 14px 13px 42px;
          font-family:'DM Sans',sans-serif; font-size:14px; outline:none;
          transition:border-color .2s,box-shadow .2s;
        }
        .cm-input:focus { border-color:#e85a2a; box-shadow:0 0 0 3px rgba(232,90,42,.12); }
        .cm-input::placeholder { color:#6e6c80; }
        .cm-submit {
          width:100%; padding:14px; border:none; border-radius:12px; cursor:pointer;
          font-family:'Syne',sans-serif; font-weight:700; font-size:15px; color:white;
          background:linear-gradient(135deg,#e85a2a,#f0a040);
          box-shadow:0 4px 20px rgba(232,90,42,.3); transition:all .2s;
        }
        .cm-submit:hover:not(:disabled) { transform:translateY(-2px); box-shadow:0 8px 32px rgba(232,90,42,.4); }
        .cm-submit:disabled { opacity:.65; cursor:not-allowed; }
        .cm-social {
          flex:1; padding:11px; border-radius:10px; background:#1a1a26;
          border:1px solid rgba(255,255,255,.14); color:#f0eee8;
          font-size:13px; font-weight:500; font-family:'DM Sans',sans-serif;
          cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px;
          transition:all .18s;
        }
        .cm-social:hover { background:#1e1e2e; transform:translateY(-1px); }
        .cm-tab {
          flex:1; padding:9px; border-radius:9px; font-size:13px; font-weight:600;
          font-family:'Syne',sans-serif; cursor:pointer; transition:all .2s; border:1px solid transparent;
        }
      `}</style>

      {/* Ambient glow */}
      <div className="fixed inset-0 pointer-events-none" style={{
        background: "radial-gradient(ellipse 80% 60% at 20% 10%,rgba(232,90,42,.10) 0%,transparent 60%),radial-gradient(ellipse 60% 50% at 80% 80%,rgba(91,155,213,.07) 0%,transparent 60%)"
      }}/>

      {/* Film strips */}
      {["left-0 border-r","right-0 border-l"].map((cls, i) => (
        <div key={i} className={`fixed ${cls} top-0 bottom-0 w-12 overflow-hidden`}
          style={{ background:"#12121a", borderColor:"rgba(255,255,255,.07)", zIndex:1 }}>
          <div className="cm-film" style={{ animationDirection: i === 1 ? "reverse" : "normal" }}/>
        </div>
      ))}

      {/* Floating emojis */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden" style={{ zIndex:0 }}>
        {FLOATERS.map(f => (
          <div key={f.id} style={{
            position:"absolute", left:`${f.left}vw`, fontSize:`${f.size}px`,
            animation:`floatUp ${f.duration}s ${f.delay}s linear infinite`
          }}>{f.emoji}</div>
        ))}
      </div>

      {/* Card */}
      <div className="cm-card relative w-full max-w-md rounded-3xl" style={{
        zIndex:10, padding:"44px 40px 40px",
        background:"rgba(18,18,26,.88)", backdropFilter:"blur(24px)",
        border:"1px solid rgba(255,255,255,.12)",
        boxShadow:"0 32px 80px rgba(0,0,0,.6),0 0 0 .5px rgba(255,255,255,.04) inset"
      }}>

        {/* Logo */}
        <div className="text-center mb-8">
          <span className="cm-icon text-5xl mb-2">🎬</span>
          <h1 className="mt-3 font-extrabold text-3xl" style={{ fontFamily:"'Syne',sans-serif", color:"#f0eee8", letterSpacing:"-0.03em" }}>
            Cine<span style={{ color:"#e85a2a" }}>Mood</span>
          </h1>
          <p className="text-sm mt-1 italic font-light" style={{ color:"#6e6c80", fontStyle:"italic" }}>
            Tamil Movies for Every Mood
          </p>
        </div>

        {/* Mode tabs */}
        <div className="flex p-1 rounded-xl mb-7" style={{ background:"#1a1a26", border:"1px solid rgba(255,255,255,.07)" }}>
          {[["login","Login"],["signup","Sign Up"]].map(([m, label]) => (
            <button key={m} onClick={() => switchMode(m)} className="cm-tab"
              style={mode === m
                ? { background:"#12121a", color:"#f0eee8", border:"1px solid rgba(255,255,255,.14)", boxShadow:"0 2px 8px rgba(0,0,0,.3)" }
                : { background:"none", color:"#6e6c80", border:"1px solid transparent" }
              }>{label}</button>
          ))}
        </div>

        {/* Alerts */}
        {error && (
          <div className="cm-alert rounded-xl px-4 py-3 text-sm mb-5"
            style={{ background:"rgba(229,53,53,.10)", border:"1px solid rgba(229,53,53,.2)", color:"#f08080" }}>
            ⚠️ {error}
          </div>
        )}
        {success && (
          <div className="cm-alert rounded-xl px-4 py-3 text-sm mb-5"
            style={{ background:"rgba(62,201,142,.10)", border:"1px solid rgba(62,201,142,.2)", color:"#3ec98e" }}>
            ✓ {success}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          {/* Name — signup only */}
          {mode === "signup" && (
            <div className="mb-4">
              <label className="block text-xs font-medium uppercase tracking-wider mb-2" style={{ color:"#6e6c80" }}>Full Name</label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-base pointer-events-none">👤</span>
                <input className="cm-input" type="text" placeholder="Your name"
                  value={form.name} onChange={e => setForm({...form, name:e.target.value})} autoComplete="name"/>
              </div>
            </div>
          )}

          {/* Email */}
          <div className="mb-4">
            <label className="block text-xs font-medium uppercase tracking-wider mb-2" style={{ color:"#6e6c80" }}>Email Address</label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-base pointer-events-none">✉️</span>
              <input className="cm-input" type="email" required placeholder="you@example.com"
                value={form.email} onChange={e => setForm({...form, email:e.target.value})} autoComplete="email"/>
            </div>
          </div>

          {/* Password */}
          <div className={mode === "login" ? "mb-2" : "mb-6"}>
            <label className="block text-xs font-medium uppercase tracking-wider mb-2" style={{ color:"#6e6c80" }}>Password</label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-base pointer-events-none">🔒</span>
              <input className="cm-input" type="password" required placeholder="Min. 6 characters" minLength={6}
                value={form.password} onChange={e => setForm({...form, password:e.target.value})}
                autoComplete={mode === "login" ? "current-password" : "new-password"}/>
            </div>
          </div>

          {/* Remember / Forgot — login only */}
          {mode === "login" && (
            <div className="flex items-center justify-between mb-6 mt-3">
              <label className="flex items-center gap-2 text-sm cursor-pointer" style={{ color:"#6e6c80" }}>
                <input type="checkbox" className="w-4 h-4" style={{ accentColor:"#e85a2a" }}/> Remember me
              </label>
              <span className="text-xs cursor-pointer" style={{ color:"#6e6c80" }}>Forgot password?</span>
            </div>
          )}

          <button type="submit" className="cm-submit" disabled={loading}>
            {loading ? "⏳ Please wait..." : mode === "login" ? "🎬 Login" : "✨ Create Account"}
          </button>
        </form>

        {/* Divider */}
        <div className="flex items-center gap-3 my-5 text-xs" style={{ color:"#6e6c80" }}>
          <div className="flex-1 h-px" style={{ background:"rgba(255,255,255,.10)" }}/>
          or continue with
          <div className="flex-1 h-px" style={{ background:"rgba(255,255,255,.10)" }}/>
        </div>

        {/* Social buttons */}
        <div className="flex gap-3">
          <button className="cm-social">
            <svg width="15" height="15" viewBox="0 0 24 24">
              <path fill="#EA4335" d="M5.266 9.765A7.077 7.077 0 0 1 12 4.909c1.69 0 3.218.6 4.418 1.582L19.91 3C17.782 1.145 15.055 0 12 0 7.27 0 3.198 2.698 1.24 6.65l4.026 3.115Z"/>
              <path fill="#34A853" d="M16.04 18.013c-1.09.703-2.474 1.078-4.04 1.078a7.077 7.077 0 0 1-6.723-4.823l-4.04 3.067A11.965 11.965 0 0 0 12 24c2.933 0 5.735-1.043 7.834-3l-3.793-2.987Z"/>
              <path fill="#4A90E2" d="M19.834 21c2.195-2.048 3.62-5.096 3.62-9 0-.71-.109-1.473-.272-2.182H12v4.637h6.436c-.317 1.559-1.17 2.766-2.395 3.558L19.834 21Z"/>
              <path fill="#FBBC05" d="M5.277 14.268A7.12 7.12 0 0 1 4.909 12c0-.782.125-1.533.357-2.235L1.24 6.65A11.934 11.934 0 0 0 0 12c0 1.92.445 3.73 1.237 5.335l4.04-3.067Z"/>
            </svg>
            Google
          </button>
          <button className="cm-social">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12Z"/>
            </svg>
            GitHub
          </button>
        </div>

        {/* Switch mode link */}
        <p className="text-center text-sm mt-6" style={{ color:"#6e6c80" }}>
          {mode === "login" ? <>Don't have an account?{" "}</> : <>Already have an account?{" "}</>}
          <button onClick={() => switchMode(mode === "login" ? "signup" : "login")}
            className="font-semibold" style={{ color:"#e85a2a", background:"none", border:"none", cursor:"pointer", fontFamily:"inherit" }}>
            {mode === "login" ? "Sign up free" : "Login"}
          </button>
        </p>
      </div>
    </div>
  );
}
