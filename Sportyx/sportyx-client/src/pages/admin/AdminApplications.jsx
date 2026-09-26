import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import AdminHeader from "../../components/AdminHeader";
import { api } from "../../api";

export default function AdminApplications() {
  const navigate = useNavigate();
  const [admin, setAdmin] = useState(null);
  const [events, setEvents] = useState([]);
  const [selectedEventId, setSelectedEventId] = useState(null);
  const [registrations, setRegistrations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [registrationsLoading, setRegistrationsLoading] = useState(false);
  const [error, setError] = useState("");

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

  async function loadEvents() {
    setLoading(true);
    setError("");
    try {
      const eventData = await api.getEvents();
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
      setRegistrations(regs);
    } catch (err) {
      setError(err.message || "Failed to load registrations");
    } finally {
      setRegistrationsLoading(false);
    }
  }

  async function handleUpdateStatus(reg, status) {
    const athleteId = reg?.athlete?.id ?? reg?.athleteId ?? reg?.athlete_id ?? reg?.athleteID;
    const eventId = reg?.event?.id ?? selectedEventId;

    if (!athleteId || !eventId) {
      setError("Cannot update: athlete id not found");
      return;
    }

    try {
      await api.updateAthleteRegistrationStatus(athleteId, eventId, status);
      await loadRegistrations(eventId);
    } catch (err) {
      setError(err.message || "Failed to update status");
    }
  }

  const getStatusColor = (status) => {
    switch (status) {
      case "SELECTED":
        return "bg-green-500/20 border-green-500/50 text-green-300";
      case "REJECTED":
        return "bg-red-500/20 border-red-500/50 text-red-300";
      case "REGISTERED":
        return "bg-blue-500/20 border-blue-500/50 text-blue-300";
      default:
        return "bg-slate-500/20 border-slate-500/50 text-slate-300";
    }
  };

  if (loading) {
    return (
      <main className="min-h-screen bg-gradient-to-br from-[#080C14] via-[#0a1428] to-[#080C14] text-slate-100">
        <AdminHeader admin={admin} />
        <div className="max-w-7xl mx-auto px-6 py-12 text-center">
          <div className="animate-spin text-5xl mb-4">⚙️</div>
          <p className="text-slate-400">Loading applications...</p>
        </div>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-[#080C14] via-[#0a1428] to-[#080C14] text-slate-100">
      <AdminHeader admin={admin} />

      <div className="max-w-7xl mx-auto px-6 py-12">
        <div className="mb-12">
          <div className="relative">
            <div className="absolute inset-0 bg-gradient-to-r from-blue-500/20 to-purple-500/20 blur-xl rounded-2xl"></div>
            <div className="relative bg-gradient-to-r from-blue-500/10 to-purple-500/10 border border-blue-500/30 rounded-2xl p-8">
              <p className="text-blue-400 text-sm font-mono tracking-widest uppercase mb-2">Athlete Management</p>
              <h1 className="text-4xl font-black mb-2">Applications</h1>
              <p className="text-slate-300">Review and manage athlete registrations across all events</p>
            </div>
          </div>
        </div>

        {error && (
          <div className="bg-red-500/10 border border-red-500/30 rounded-xl p-4 mb-6 text-red-300 flex items-center gap-3">
            <span className="text-xl">✕</span> {error}
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          {/* Events Sidebar */}
          <div className="lg:col-span-1">
            <h2 className="text-lg font-bold mb-4">Events</h2>
            <div className="space-y-2">
              {events.length === 0 ? (
                <p className="text-slate-400 text-sm">No events found</p>
              ) : (
                events.map((event) => (
                  <button
                    key={event.id}
                    onClick={() => {
                      setSelectedEventId(event.id);
                      loadRegistrations(event.id);
                    }}
                    className={`w-full text-left p-4 rounded-xl border transition-all ${
                      selectedEventId === event.id
                        ? "bg-cyan-500/20 border-cyan-500/50 shadow-lg shadow-cyan-500/10"
                        : "border-white/10 bg-white/[0.02] hover:border-white/20 hover:bg-white/[0.04]"
                    }`}
                  >
                    <p className="font-semibold text-sm text-cyan-400">{event.title}</p>
                    <p className="text-xs text-slate-500 mt-1">{event.sportCategory}</p>
                  </button>
                ))
              )}
            </div>
          </div>

          {/* Applications List */}
          <div className="lg:col-span-3">
            {selectedEventId ? (
              <div>
                <h2 className="text-xl font-bold mb-6">Event Registrations</h2>

                {registrationsLoading ? (
                  <div className="text-center py-12">
                    <div className="animate-spin text-4xl mb-3">⚙️</div>
                    <p className="text-slate-300">Loading registrations...</p>
                  </div>
                ) : registrations.length === 0 ? (
                  <div className="rounded-xl border border-dashed border-white/20 bg-white/[0.02] p-12 text-center">
                    <p className="text-slate-400 text-lg">No registrations for this event</p>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {registrations.map((reg) => {
                      const athleteName = reg?.athlete?.fullName || reg?.athlete?.full_name || "Athlete";
                      const athleteEmail = reg?.athlete?.email || "N/A";
                      const status = reg?.registrationStatus || reg?.registration_status || "REGISTERED";

                      const statusConfig = {
                        SELECTED: { bg: "bg-green-500/20", border: "border-green-500/50", text: "text-green-300", icon: "✓", label: "Selected" },
                        REGISTERED: { bg: "bg-blue-500/20", border: "border-blue-500/50", text: "text-blue-300", icon: "⟳", label: "Pending Review" },
                        REJECTED: { bg: "bg-red-500/20", border: "border-red-500/50", text: "text-red-300", icon: "✕", label: "Rejected" },
                      };

                      const config = statusConfig[status] || statusConfig.REGISTERED;

                      return (
                        <div
                          key={reg.id}
                          className={`rounded-xl border ${config.border} ${config.bg} p-5 transition-all hover:shadow-lg`}
                        >
                          <div className="flex items-start justify-between gap-4 mb-4 flex-wrap">
                            <div className="flex-1">
                              <div className="flex items-center gap-3 mb-2">
                                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center text-white font-bold">
                                  {athleteName.charAt(0)}
                                </div>
                                <div>
                                  <p className="font-semibold text-cyan-300">{athleteName}</p>
                                  <p className="text-xs text-slate-500">{athleteEmail}</p>
                                </div>
                              </div>
                            </div>
                            <div className={`px-3 py-1 rounded-full border text-xs font-semibold flex items-center gap-1 ${config.text}`}>
                              <span>{config.icon}</span>
                              {config.label}
                            </div>
                          </div>

                          <div className="flex gap-2 flex-wrap">
                            <button
                              onClick={() => handleUpdateStatus(reg, "SELECTED")}
                              className="px-4 py-2 bg-green-500/30 border border-green-500/50 text-green-300 rounded-lg text-sm font-semibold hover:bg-green-500/50 transition-colors"
                            >
                              ✓ Select
                            </button>
                            <button
                              onClick={() => handleUpdateStatus(reg, "REGISTERED")}
                              className="px-4 py-2 bg-blue-500/30 border border-blue-500/50 text-blue-300 rounded-lg text-sm font-semibold hover:bg-blue-500/50 transition-colors"
                            >
                              ⟳ Pending
                            </button>
                            <button
                              onClick={() => handleUpdateStatus(reg, "REJECTED")}
                              className="px-4 py-2 bg-red-500/30 border border-red-500/50 text-red-300 rounded-lg text-sm font-semibold hover:bg-red-500/50 transition-colors"
                            >
                              ✕ Reject
                            </button>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            ) : (
              <div className="rounded-xl border border-dashed border-white/20 bg-white/[0.02] p-16 text-center">
                <p className="text-5xl mb-4">📋</p>
                <p className="text-slate-400 text-lg">Select an event to view applications</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </main>
  );
}
