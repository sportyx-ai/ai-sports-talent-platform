import { useLocation, useNavigate } from "react-router-dom";

export default function AdminHeader({ admin }) {
  const navigate = useNavigate();
  const location = useLocation();

  const navItems = [
    { label: "Dashboard", path: "/admin/home", icon: "🏠" },
    { label: "Create Event", path: "/admin/create-event", icon: "📅" },
    { label: "All Events", path: "/admin/events", icon: "🎯" },
    { label: "Applications", path: "/admin/applications", icon: "📋" },
    { label: "Video Reviews", path: "/admin/videos", icon: "🎬" },
  ];

  const isActive = (path) => location.pathname === path;

  return (
    <header className="sticky top-0 z-50 bg-gradient-to-r from-[#0a0f1a] via-[#0e1524] to-[#0a0f1a] border-b border-cyan-500/20 backdrop-blur-sm">
      <div className="max-w-7xl mx-auto px-6">
        {/* Top Row - Logo and Logout */}
        <div className="flex items-center justify-between py-4 border-b border-white/5">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center">
              <span className="text-xl font-black text-white">⚡</span>
            </div>
            <div>
              <p className="text-cyan-400 text-xs font-mono tracking-widest uppercase">Admin Portal</p>
              <h1 className="text-lg font-black">Sportyx</h1>
            </div>
          </div>
          <div className="flex items-center gap-6">
            <div className="text-right">
              <p className="text-sm font-semibold">{admin?.fullName || "Admin"}</p>
              <p className="text-xs text-slate-400">{admin?.email}</p>
            </div>
            <button
              onClick={() => {
                localStorage.removeItem("sportyx_admin");
                navigate("/login");
              }}
              className="px-4 py-2 text-sm border border-white/20 rounded-lg text-slate-300 hover:border-red-400 hover:text-red-400 transition-colors duration-300"
            >
              Logout
            </button>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex gap-1 py-4 overflow-x-auto scrollbar-hide">
          {navItems.map((item) => {
            const active = isActive(item.path);
            return (
              <button
                key={item.path}
                onClick={() => navigate(item.path)}
                className={`px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-300 flex items-center gap-2 whitespace-nowrap ${
                  active
                    ? "bg-gradient-to-r from-cyan-500 to-blue-600 text-[#080C14] shadow-lg shadow-cyan-500/30"
                    : "text-slate-300 hover:bg-white/5 border border-transparent hover:border-white/10"
                }`}
              >
                <span className="text-lg">{item.icon}</span>
                {item.label}
              </button>
            );
          })}
        </nav>
      </div>
    </header>
  );
}
