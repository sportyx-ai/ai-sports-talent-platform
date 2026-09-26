import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import AdminHeader from "../../components/AdminHeader";
import { api } from "../../api";

export default function AdminEvents() {
  const navigate = useNavigate();
  const [admin, setAdmin] = useState(null);
  const [events, setEvents] = useState([]);
  const [filteredEvents, setFilteredEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selectedEventId, setSelectedEventId] = useState(null);
  const [eventRegistrations, setEventRegistrations] = useState([]);
  const [registrationsLoading, setRegistrationsLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");

  useEffect(() => {
    const raw = localStorage.getItem("sportyx_admin");
    if (!raw) {
      navigate("/login");
      return;
    }
    const parsed = JSON.parse(raw);
    setAdmin(parsed);
    loadEvents();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [navigate]);

  useEffect(() => {
    // Filter out events with no title (empty events)
    const valid = events.filter(e => e.title && e.title.trim());
    let filtered = valid;

    if (searchQuery.trim()) {
      filtered = valid.filter(e =>
        e.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        e.sportCategory?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        e.location?.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }

    setFilteredEvents(filtered);
  }, [events, searchQuery]);

  async function loadEvents() {
    setLoading(true);
    setError("");
    try {
      const eventData = await api.getEvents();
      // Filter valid events
      const validEvents = Array.isArray(eventData) ? eventData.filter(e => e.title && e.title.trim()) : [];
      setEvents(validEvents);
    } catch (err) {
      setError(err.message || "Failed to load events");
    } finally {
      setLoading(false);
    }
  }

  async function loadRegistrations(eventId) {
    setRegistrationsLoading(true);
    setError("");
    try {
      const regs = await api.getEventRegistrations(eventId);
      setEventRegistrations(regs);
    } catch (err) {
      setError(err.message || "Failed to load registrations");
    } finally {
      setRegistrationsLoading(false);
    }
  }

  async function handleUpdateRegistration(reg, status) {
    const athleteId = reg?.athlete?.id ?? reg?.athleteId ?? reg?.athlete_id ?? reg?.athleteID;
    const eventId = reg?.event?.id ?? selectedEventId;

    if (!athleteId || !eventId) {
      setError("Cannot update registration: athlete id not found");
      return;
    }

    try {
      await api.updateAthleteRegistrationStatus(athleteId, eventId, status);
      await loadRegistrations(eventId);
    } catch (err) {
      setError(err.message || "Failed to update registration");
    }
  }

  if (loading) {
    return (
      <main className="min-h-screen bg-gradient-to-br from-[#080C14] via-[#0a1428] to-[#080C14] text-slate-100">
        <AdminHeader admin={admin} />
        <div className="max-w-7xl mx-auto px-6 py-12 text-center">
          <div className="animate-spin text-4xl mb-4">⚙️</div>
          <p className="text-slate-400">Loading events...</p>
        </div>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-[#080C14] via-[#0a1428] to-[#080C14] text-slate-100">
      <AdminHeader admin={admin} />

      <div className="max-w-7xl mx-auto px-6 py-12">
        {/* Hero Section */}
        <div className="mb-12">
          <div className="relative">
            <div className="absolute inset-0 bg-gradient-to-r from-blue-500/20 to-cyan-500/20 blur-xl rounded-2xl"></div>
            <div className="relative bg-gradient-to-r from-blue-500/10 to-cyan-500/10 border border-blue-500/30 rounded-2xl p-8">
              <p className="text-blue-400 text-sm font-mono tracking-widest uppercase mb-2">Event Management</p>
              <h1 className="text-4xl font-black mb-2">All Events</h1>
              <p className="text-slate-300">Manage created events and athlete registrations</p>
            </div>
          </div>
        </div>

        {error && (
          <div className="bg-red-500/10 border border-red-500/30 rounded-xl p-4 mb-6 text-red-300 flex items-center gap-3">
            <span className="text-xl">✕</span> {error}
          </div>
        )}

        {/* Search Bar */}
        <div className="mb-8">
          <input
            type="text"
            placeholder="🔍 Search events by title, sport, or location..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full rounded-xl bg-white/[0.05] border border-white/10 px-6 py-4 text-slate-100 placeholder-slate-600 focus:border-cyan-500 focus:bg-white/[0.08] focus:outline-none transition-all"
          />
        </div>

        {/* Events Grid */}
        {filteredEvents.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-white/20 bg-white/[0.02] p-16 text-center">
            <p className="text-5xl mb-4">📅</p>
            <p className="text-slate-400 text-lg mb-4">
              {searchQuery ? "No events match your search" : "No events created yet"}
            </p>
            {!searchQuery && (
              <button
                onClick={() => navigate("/admin/create-event")}
                className="px-6 py-2 bg-cyan-500 text-[#080C14] rounded-lg font-semibold hover:bg-cyan-400 transition-colors inline-block"
              >
                Create First Event →
              </button>
            )}
          </div>
        ) : (
          <div className="space-y-6">
            {/* Summary Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="rounded-xl border border-cyan-500/30 bg-cyan-500/10 p-4">
                <p className="text-slate-400 text-sm mb-1">Total Events</p>
                <p className="text-3xl font-black text-cyan-400">{filteredEvents.length}</p>
              </div>
              <div className="rounded-xl border border-blue-500/30 bg-blue-500/10 p-4">
                <p className="text-slate-400 text-sm mb-1">Total Registrations</p>
                <p className="text-3xl font-black text-blue-400">{eventRegistrations.length}</p>
              </div>
              <div className="rounded-xl border border-purple-500/30 bg-purple-500/10 p-4">
                <p className="text-slate-400 text-sm mb-1">Selected Athletes</p>
                <p className="text-3xl font-black text-purple-400">
                  {eventRegistrations.filter(r => r.registrationStatus === "SELECTED").length}
                </p>
              </div>
            </div>

            {/* Events List */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredEvents.map((item) => (
                <div
                  key={item.id}
                  onClick={() => {
                    setSelectedEventId(item.id);
                    loadRegistrations(item.id);
                  }}
                  className={`group rounded-2xl border transition-all cursor-pointer overflow-hidden ${
                    selectedEventId === item.id
                      ? "border-cyan-500/70 bg-cyan-500/10 shadow-cyan-500/20 shadow-lg"
                      : "border-white/10 bg-white/[0.02] hover:border-cyan-500/50 hover:shadow-lg hover:shadow-cyan-500/10"
                  }`}
                >
                  {/* Event Poster */}
                  {item.posterUrl ? (
                    <div className="relative overflow-hidden h-48 bg-slate-900">
                      <img
                        src={item.posterUrl}
                        alt={item.title}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
                    </div>
                  ) : (
                    <div className="w-full h-48 bg-gradient-to-br from-cyan-500/20 to-blue-500/20 flex items-center justify-center group-hover:from-cyan-500/30 group-hover:to-blue-500/30 transition-colors">
                      <p className="text-slate-500 text-4xl">🎬</p>
                    </div>
                  )}

                  {/* Event Info */}
                  <div className="p-5">
                    <div className="flex items-start justify-between gap-3 mb-3">
                      <h3 className="font-bold text-lg text-cyan-400 line-clamp-2">{item.title}</h3>
                      <span className="text-xs bg-cyan-500/20 text-cyan-300 px-2 py-1 rounded-full whitespace-nowrap">
                        {item.skillLevelRequired}
                      </span>
                    </div>

                    <div className="space-y-2 text-sm text-slate-400 mb-4">
                      <p className="flex items-center gap-2">
                        <span>🏆</span>
                        <span>{item.sportCategory}</span>
                      </p>
                      <p className="flex items-center gap-2">
                        <span>📍</span>
                        <span className="truncate">{item.location}</span>
                      </p>
                      <p className="flex items-center gap-2">
                        <span>📅</span>
                        <span>{new Date(item.eventDate).toLocaleDateString("en-US", { month: "short", day: "numeric" })}</span>
                      </p>
                    </div>

                    <button
                      className={`w-full py-2 rounded-lg font-semibold transition-all text-sm ${
                        selectedEventId === item.id
                          ? "bg-cyan-500 text-[#080C14]"
                          : "bg-white/10 text-cyan-300 hover:bg-cyan-500/20"
                      }`}
                    >
                      View Registrations
                    </button>
                  </div>
                </div>
              ))}
            </div>

            {/* Registrations Section */}
            {selectedEventId && (
              <div className="rounded-2xl border border-white/10 bg-white/[0.02] backdrop-blur-sm p-8 mt-8">
                <div className="flex items-center justify-between mb-6">
                  <div>
                    <h2 className="text-2xl font-bold mb-2">Event Registrations</h2>
                    <p className="text-slate-400 text-sm">
                      {eventRegistrations.length} athlete{eventRegistrations.length !== 1 ? "s" : ""} registered
                    </p>
                  </div>
                  <button
                    onClick={() => setSelectedEventId(null)}
                    className="text-slate-400 hover:text-slate-200 text-3xl hover:bg-white/10 w-12 h-12 rounded-lg flex items-center justify-center transition-colors"
                  >
                    ✕
                  </button>
                </div>

                {registrationsLoading ? (
                  <p className="text-slate-300 text-center py-8">Loading registrations...</p>
                ) : eventRegistrations.length === 0 ? (
                  <p className="text-slate-400 text-center py-8">No registrations yet for this event</p>
                ) : (
                  <div className="space-y-3 max-h-96 overflow-y-auto">
                    {eventRegistrations.map((reg) => {
                      const athleteName = reg?.athlete?.fullName || reg?.athlete?.full_name || "Athlete";
                      const status = reg?.registrationStatus || reg?.registration_status || "REGISTERED";

                      const statusConfig = {
                        SELECTED: { bg: "bg-green-500/20", border: "border-green-500/50", text: "text-green-300", label: "✓ Selected" },
                        REGISTERED: { bg: "bg-blue-500/20", border: "border-blue-500/50", text: "text-blue-300", label: "⟳ Pending" },
                        REJECTED: { bg: "bg-red-500/20", border: "border-red-500/50", text: "text-red-300", label: "✕ Rejected" },
                      };

                      const config = statusConfig[status] || statusConfig.REGISTERED;

                      return (
                        <article
                          key={reg.id}
                          className={`rounded-xl border ${config.border} ${config.bg} p-4 transition-all hover:shadow-lg`}
                        >
                          <div className="flex items-center justify-between gap-4 flex-wrap">
                            <div className="flex-1 min-w-0">
                              <p className="font-semibold text-cyan-300">{athleteName}</p>
                              <p className={`text-xs font-semibold ${config.text}`}>{config.label}</p>
                            </div>

                            <div className="flex gap-2">
                              <button
                                onClick={() => handleUpdateRegistration(reg, "SELECTED")}
                                className="px-4 py-2 bg-green-500/30 border border-green-500/50 text-green-300 rounded-lg text-xs font-semibold hover:bg-green-500/50 transition-colors"
                              >
                                Select
                              </button>
                              <button
                                onClick={() => handleUpdateRegistration(reg, "REJECTED")}
                                className="px-4 py-2 bg-red-500/30 border border-red-500/50 text-red-300 rounded-lg text-xs font-semibold hover:bg-red-500/50 transition-colors"
                              >
                                Reject
                              </button>
                            </div>
                          </div>
                        </article>
                      );
                    })}
                  </div>
                )}
              </div>
            )}
          </div>
        )}
      </div>
    </main>
  );
}
