export default function Footer() {
  return (
    <footer className="bg-[#080C14] border-t border-white/5">
      <div className="max-w-7xl mx-auto px-6 lg:px-12 py-8 flex flex-col sm:flex-row items-center justify-between gap-4">
        {/* Brand */}
        <div className="flex items-center gap-3">
          <span
            className="text-xl font-black text-white tracking-wider"
            style={{ fontFamily: "'Bebas Neue', sans-serif", letterSpacing: "0.08em" }}
          >
            SPORT
            <span className="text-cyan-400">YX</span>
          </span>
          <span className="hidden sm:block w-px h-4 bg-white/10" />
          <span className="hidden sm:block text-slate-500 text-xs font-mono tracking-widest uppercase">
            Admin Portal
          </span>
        </div>

        {/* Center */}
        <p className="text-slate-600 text-xs font-mono">
          © 2026 Sportyx. All rights reserved.
        </p>

        {/* Right */}
        <div className="flex items-center gap-1.5">
          <span className="w-1.5 h-1.5 rounded-full bg-cyan-500 animate-pulse" />
          <span className="text-slate-500 text-xs font-mono tracking-wider">System Operational</span>
        </div>
      </div>
    </footer>
  );
}