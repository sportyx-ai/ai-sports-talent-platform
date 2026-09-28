import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../../api";

export default function AdminLogin() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const onSubmit = async (event) => {
    event.preventDefault();
    setError("");
    setLoading(true);
    try {
      const admins = await api.getAdmins();
      const matched = admins.find(
        (item) =>
          (item.email || "").toLowerCase() === email.trim().toLowerCase() &&
          (item.passwordHash || "") === password.trim() &&
          (item.isActive === undefined || item.isActive),
      );
      if (!matched) {
        throw new Error("Invalid credentials");
      }
      localStorage.setItem("sportyx_admin", JSON.stringify(matched));
      navigate("/admin/home");
    } catch (err) {
      setError(err.message || "Login failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="min-h-screen bg-[#080C14] text-slate-100 flex items-center justify-center px-6">
      <form
        onSubmit={onSubmit}
        className="w-full max-w-md rounded-xl border border-white/10 bg-white/[0.03] p-8"
      >
        <p className="text-cyan-400 text-xs font-mono tracking-widest uppercase mb-3">
          Admin Portal
        </p>
        <h1 className="text-3xl font-black mb-6">Admin Login</h1>
        <div className="space-y-4">
          <input
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            type="email"
            placeholder="Email"
            className="w-full rounded-lg bg-[#0e1524] border border-white/10 px-4 py-3 outline-none focus:border-cyan-500"
            required
          />
          <input
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            type="password"
            placeholder="Password"
            className="w-full rounded-lg bg-[#0e1524] border border-white/10 px-4 py-3 outline-none focus:border-cyan-500"
            required
          />
          {error ? <p className="text-red-400 text-sm">{error}</p> : null}
          <button
            disabled={loading}
            type="submit"
            className="w-full px-4 py-3 bg-cyan-500 text-[#080C14] font-bold rounded-lg disabled:opacity-60"
          >
            {loading ? "Signing in..." : "Sign In"}
          </button>
        </div>
      </form>
    </main>
  );
}
