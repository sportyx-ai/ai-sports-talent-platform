import { motion } from "framer-motion";
import { useNavigate } from "react-router-dom";

export default function HeroSection() {
  const navigate = useNavigate();

  return (
    <section className="relative min-h-screen flex items-center overflow-hidden bg-[#080C14]">
      {/* Background grid */}
      <div
        className="absolute inset-0 opacity-[0.04]"
        style={{
          backgroundImage:
            "linear-gradient(#00E5FF 1px, transparent 1px), linear-gradient(90deg, #00E5FF 1px, transparent 1px)",
          backgroundSize: "60px 60px",
        }}
      />

      {/* Glow orbs */}
      <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-blue-600/10 rounded-full blur-3xl pointer-events-none" />

      <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-12 w-full">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center min-h-screen py-24">
          {/* Left */}
          <div className="flex flex-col gap-6">
            {/* Badge */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="inline-flex items-center gap-2 w-fit px-3 py-1.5 rounded-full border border-cyan-500/30 bg-cyan-500/5"
            >
              <span className="w-1.5 h-1.5 rounded-full bg-cyan-400 animate-pulse" />
              <span className="text-cyan-400 text-xs font-mono tracking-widest uppercase">
                Admin Portal
              </span>
            </motion.div>

            {/* Brand */}
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
            >
              <h1
                className="text-7xl lg:text-8xl font-black tracking-tight text-white leading-none"
                style={{ fontFamily: "'Bebas Neue', sans-serif", letterSpacing: "0.04em" }}
              >
                SPORT
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-blue-500">
                  YX
                </span>
              </h1>
            </motion.div>

            {/* Tagline */}
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="text-2xl font-semibold text-slate-300 tracking-wide"
              style={{ fontFamily: "'Barlow Condensed', sans-serif" }}
            >
              Control.{" "}
              <span className="text-cyan-400">Analyze.</span>{" "}
              Elevate.
            </motion.p>

            {/* Description */}
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="text-slate-400 text-base leading-relaxed max-w-md"
            >
              The central command for sports operations. Manage events at scale,
              track athlete performance, and surface insights that drive results —
              all from one secure platform.
            </motion.p>

            {/* CTA */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.4 }}
              className="flex items-center gap-4 pt-2"
            >
              <button
                onClick={() => navigate("/login")}
                className="group relative px-8 py-3.5 bg-cyan-500 text-[#080C14] font-bold text-sm tracking-widest uppercase rounded overflow-hidden transition-all duration-300 hover:shadow-[0_0_30px_rgba(0,229,255,0.4)]"
              >
                <span className="relative z-10">Admin Login</span>
                <div className="absolute inset-0 bg-gradient-to-r from-cyan-400 to-blue-400 translate-x-[-100%] group-hover:translate-x-0 transition-transform duration-300" />
              </button>

              <a
                href="#features"
                className="text-slate-400 text-sm tracking-wider hover:text-cyan-400 transition-colors duration-200 underline underline-offset-4 decoration-slate-600 hover:decoration-cyan-400"
              >
                Explore features →
              </a>
            </motion.div>
          </div>

          {/* Right — Spline / 3D placeholder */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.3 }}
            className="relative w-full aspect-square max-w-lg mx-auto"
          >
            {/* Decorative border ring */}
            <div className="absolute inset-0 rounded-2xl border border-cyan-500/20 bg-gradient-to-br from-cyan-500/5 via-transparent to-blue-600/5" />

            {/* Corner accents */}
            {[
              "top-0 left-0 border-t-2 border-l-2",
              "top-0 right-0 border-t-2 border-r-2",
              "bottom-0 left-0 border-b-2 border-l-2",
              "bottom-0 right-0 border-b-2 border-r-2",
            ].map((cls, i) => (
              <div
                key={i}
                className={`absolute w-6 h-6 border-cyan-400 ${cls}`}
              />
            ))}

            {/* Spline embed goes here */}
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 text-center px-8">
              {/* Replace this div's contents with your <Spline> component */}
              <div className="w-16 h-16 rounded-full border-2 border-cyan-500/40 flex items-center justify-center mb-2">
                <svg
                  className="w-7 h-7 text-cyan-400"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  strokeWidth={1.5}
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M15.91 11.672a.375.375 0 010 .656l-5.603 3.113a.375.375 0 01-.557-.328V8.887c0-.286.307-.466.557-.328l5.603 3.113z"
                  />
                </svg>
              </div>
              <p className="text-slate-500 text-xs font-mono tracking-widest uppercase">
                Spline 3D Scene
              </p>
              <p className="text-slate-600 text-xs">
                Replace with{" "}
                <code className="text-cyan-600 text-[11px]">&lt;Spline url="…" /&gt;</code>
              </p>
            </div>

            {/* Rotating ring decoration */}
            <div
              className="absolute inset-6 rounded-full border border-dashed border-cyan-500/10 animate-spin"
              style={{ animationDuration: "20s" }}
            />
          </motion.div>
        </div>
      </div>
    </section>
  );
}