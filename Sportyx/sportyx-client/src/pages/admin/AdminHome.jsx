import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import AdminHeader from "../../components/AdminHeader";
import { api } from "../../api";

export default function AdminHome() {
  const navigate = useNavigate();
  const [admin, setAdmin] = useState(null);
  const [managers, setManagers] = useState([]);
  const [events, setEvents] = useState([]);
  const [videos, setVideos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const raw = localStorage.getItem("sportyx_admin");
    if (!raw) {
      navigate("/login");
      return;
    }
    const parsed = JSON.parse(raw);
    setAdmin(parsed);
    loadData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [navigate]);

  async function loadData() {
    setLoading(true);
    setError("");
    try {
      const [managerData, eventData, videoData] = await Promise.all([
        api.getManagers(),
        api.getEvents(),
        api.getPendingVideos(),
      ]);
      const validEvents = Array.isArray(eventData) ? eventData.filter(e => e.title && e.title.trim()) : [];
      setManagers(managerData);
      setEvents(validEvents);
      setVideos(videoData);
    } catch (err) {
      setError(err.message || "Failed to load data");
    } finally {
      setLoading(false);
    }
  }

  const pendingVideos = videos.filter(v => v.adminReviewStatus === "PENDING").length;
  const approvedVideos = videos.filter(v => v.adminReviewStatus === "REVIEWED").length;

  if (loading) {
    return (
      <main className="min-h-screen bg-gradient-to-br from-[#080C14] via-[#0a1428] to-[#080C14] text-slate-100">
        <AdminHeader admin={admin} />
        <div className="max-w-7xl mx-auto px-6 py-12 text-center">
          <div className="animate-spin text-5xl mb-4">⚙️</div>
          <p className="text-slate-400">Loading dashboard...</p>
        </div>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-[#080C14] via-[#0a1428] to-[#080C14] text-slate-100">
      <AdminHeader admin={admin} />

      <div className="max-w-7xl mx-auto px-6 py-12">
        {error && (
          <div className="bg-red-500/10 border border-red-500/30 rounded-xl p-4 mb-6 text-red-300 flex items-center gap-3">
            <span className="text-xl">✕</span> {error}
          </div>
        )}

        {/* Welcome Banner */}
        <div className="mb-12">
          <div className="relative overflow-hidden rounded-2xl">
            <div className="absolute inset-0 bg-gradient-to-r from-cyan-500/20 via-blue-500/20 to-purple-500/20 blur-xl"></div>
            <div className="relative bg-gradient-to-r from-cyan-500/10 via-blue-500/10 to-purple-500/10 border border-cyan-500/30 rounded-2xl p-8">
              <h1 className="text-4xl font-black mb-2">Welcome back, {admin?.fullName || "Admin"}! 👋</h1>
              <p className="text-slate-300 text-lg">Here's your platform overview and quick actions</p>
            </div>
          </div>
        </div>

        {/* Key Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 mb-12">
          <div className="rounded-xl border border-cyan-500/30 bg-cyan-500/10 backdrop-blur-sm p-6 hover:border-cyan-500/50 hover:shadow-lg hover:shadow-cyan-500/10 transition-all">
            <div className="flex items-center justify-between mb-3">
              <p className="text-slate-400 text-sm font-semibold">Managers</p>
              <span className="text-2xl">👥</span>
            </div>
            <h3 className="text-4xl font-black text-cyan-400 mb-1">{managers.length}</h3>
            <p className="text-xs text-slate-500">Active in system</p>
          </div>

          <div className="rounded-xl border border-blue-500/30 bg-blue-500/10 backdrop-blur-sm p-6 hover:border-blue-500/50 hover:shadow-lg hover:shadow-blue-500/10 transition-all">
            <div className="flex items-center justify-between mb-3">
              <p className="text-slate-400 text-sm font-semibold">Events</p>
              <span className="text-2xl">🎯</span>
            </div>
            <h3 className="text-4xl font-black text-blue-400 mb-1">{events.length}</h3>
            <p className="text-xs text-slate-500">Created</p>
          </div>

          <div className="rounded-xl border border-yellow-500/30 bg-yellow-500/10 backdrop-blur-sm p-6 hover:border-yellow-500/50 hover:shadow-lg hover:shadow-yellow-500/10 transition-all">
            <div className="flex items-center justify-between mb-3">
              <p className="text-slate-400 text-sm font-semibold">Pending</p>
              <span className="text-2xl">⏳</span>
            </div>
            <h3 className="text-4xl font-black text-yellow-400 mb-1">{pendingVideos}</h3>
            <p className="text-xs text-slate-500">Videos to review</p>
          </div>

          <div className="rounded-xl border border-green-500/30 bg-green-500/10 backdrop-blur-sm p-6 hover:border-green-500/50 hover:shadow-lg hover:shadow-green-500/10 transition-all">
            <div className="flex items-center justify-between mb-3">
              <p className="text-slate-400 text-sm font-semibold">Approved</p>
              <span className="text-2xl">✓</span>
            </div>
            <h3 className="text-4xl font-black text-green-400 mb-1">{approvedVideos}</h3>
            <p className="text-xs text-slate-500">Reviewed</p>
          </div>

          <div className="rounded-xl border border-purple-500/30 bg-purple-500/10 backdrop-blur-sm p-6 hover:border-purple-500/50 hover:shadow-lg hover:shadow-purple-500/10 transition-all">
            <div className="flex items-center justify-between mb-3">
              <p className="text-slate-400 text-sm font-semibold">Total</p>
              <span className="text-2xl">🎬</span>
            </div>
            <h3 className="text-4xl font-black text-purple-400 mb-1">{videos.length}</h3>
            <p className="text-xs text-slate-500">Videos</p>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mb-12">
          <h2 className="text-2xl font-black mb-6">Quick Actions</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <button
              onClick={() => navigate("/admin/create-event")}
              className="group rounded-2xl border border-cyan-500/30 bg-gradient-to-br from-cyan-500/10 to-blue-500/10 p-8 hover:border-cyan-500/50 hover:shadow-lg hover:shadow-cyan-500/20 transition-all text-left"
            >
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-bold text-cyan-400">📅 Create Event</h3>
                <span className="text-2xl group-hover:translate-x-1 transition-transform">→</span>
              </div>
              <p className="text-slate-400 text-sm">Create new sports events with poster and details</p>
            </button>

            <button
              onClick={() => navigate("/admin/applications")}
              className="group rounded-2xl border border-blue-500/30 bg-gradient-to-br from-blue-500/10 to-purple-500/10 p-8 hover:border-blue-500/50 hover:shadow-lg hover:shadow-blue-500/20 transition-all text-left"
            >
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-bold text-blue-400">📋 Applications</h3>
                <span className="text-2xl group-hover:translate-x-1 transition-transform">→</span>
              </div>
              <p className="text-slate-400 text-sm">Manage athlete registrations across all events</p>
            </button>

            <button
              onClick={() => navigate("/admin/videos")}
              className="group rounded-2xl border border-purple-500/30 bg-gradient-to-br from-purple-500/10 to-pink-500/10 p-8 hover:border-purple-500/50 hover:shadow-lg hover:shadow-purple-500/20 transition-all text-left"
            >
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-bold text-purple-400">🎬 Video Reviews</h3>
                <span className="text-2xl group-hover:translate-x-1 transition-transform">→</span>
              </div>
              <p className="text-slate-400 text-sm">Review and approve athlete performance videos</p>
            </button>
          </div>
        </div>

        {/* Recent Events */}
        {events.length > 0 && (
          <div className="mb-12">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-black">Recent Events</h2>
              <button
                onClick={() => navigate("/admin/events")}
                className="text-cyan-400 hover:text-cyan-300 text-sm font-semibold"
              >
                View All →
              </button>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {events.slice(0, 2).map((event) => (
                <div
                  key={event.id}
                  className="rounded-xl border border-white/10 bg-white/[0.02] overflow-hidden hover:border-white/20 transition-all group"
                >
                  {event.posterUrl && (
                    <div className="relative h-32 overflow-hidden">
                      <img
                        src={event.posterUrl}
                        alt={event.title}
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent"></div>
                    </div>
                  )}
                  <div className="p-4">
                    <h3 className="font-bold text-lg text-cyan-400 mb-2">{event.title}</h3>
                    <div className="flex items-center justify-between text-xs text-slate-400">
                      <span>🏆 {event.sportCategory}</span>
                      <span>📍 {event.location}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Managers List */}
        <div>
          <h2 className="text-2xl font-black mb-6">Managers</h2>
          {managers.length === 0 ? (
            <div className="rounded-xl border border-dashed border-white/20 bg-white/[0.02] p-12 text-center">
              <p className="text-slate-400 text-lg">No managers in the system yet</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {managers.map((manager) => (
                <div
                  key={manager.id}
                  className="rounded-xl border border-white/10 bg-white/[0.02] p-4 hover:border-white/20 hover:bg-white/[0.04] transition-all"
                >
                  <div className="flex items-center gap-3 mb-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center text-white font-bold">
                      {manager.fullName?.charAt(0) || "U"}
                    </div>
                    <div>
                      <h3 className="font-semibold text-cyan-400">{manager.fullName}</h3>
                      <p className="text-xs text-slate-500">{manager.organization || "—"}</p>
                    </div>
                  </div>
                  <p className="text-sm text-slate-400 truncate">{manager.email}</p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </main>
  );
}
