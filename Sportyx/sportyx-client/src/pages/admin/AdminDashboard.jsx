import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../../api";

const tabs = ["Managers", "Events", "Pending Videos"];

export default function AdminDashboard() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState(tabs[0]);
  const [admin, setAdmin] = useState(null);
  const [managers, setManagers] = useState([]);
  const [events, setEvents] = useState([]);
  const [pendingVideos, setPendingVideos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selectedEventId, setSelectedEventId] = useState(null);
  const [eventRegistrations, setEventRegistrations] = useState([]);
  const [registrationsLoading, setRegistrationsLoading] = useState(false);
  const [eventForm, setEventForm] = useState({
    title: "",
    description: "",
    sportCategory: "",
    skillLevelRequired: "BEGINNER",
    location: "",
    eventDate: "",
    registrationDeadline: "",
    posterFile: null,
  });
  const [posterPreview, setPosterPreview] = useState(null);

  const adminId = useMemo(() => admin?.id, [admin]);

  useEffect(() => {
    const raw = localStorage.getItem("sportyx_admin");
    if (!raw) {
      navigate("/login");
      return;
    }
    const parsed = JSON.parse(raw);
    setAdmin(parsed);
    loadAllData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [navigate]);

  async function loadAllData() {
    setLoading(true);
    setError("");
    try {
      const [managerData, eventData, pendingData] = await Promise.all([
        api.getManagers(),
        api.getEvents(),
        api.getPendingVideos(),
      ]);
      setManagers(managerData);
      setEvents(eventData);
      setPendingVideos(pendingData);
    } catch (err) {
      setError(err.message || "Failed to fetch data");
    } finally {
      setLoading(false);
    }
  }

  async function handleCreateEvent(event) {
    event.preventDefault();
    if (!adminId) return;
    try {
      const eventData = { ...eventForm };
      delete eventData.posterFile;
      const createdEvent = await api.createEvent(adminId, eventData);

      if (eventForm.posterFile) {
        await api.uploadEventPoster(createdEvent.id, eventForm.posterFile);
      }

      setEventForm({
        title: "",
        description: "",
        sportCategory: "",
        skillLevelRequired: "BEGINNER",
        location: "",
        eventDate: "",
        registrationDeadline: "",
        posterFile: null,
      });
      setPosterPreview(null);
      await loadAllData();
    } catch (err) {
      setError(err.message || "Failed to create event");
    }
  }

  function handlePosterChange(e) {
    const file = e.target.files?.[0];
    if (file) {
      setEventForm((s) => ({ ...s, posterFile: file }));
      const reader = new FileReader();
      reader.onloadend = () => {
        setPosterPreview(reader.result);
      };
      reader.readAsDataURL(file);
    }
  }

  async function handleReview(videoId, status) {
    try {
      await api.reviewVideo(videoId, {
        feedback: status === "REVIEWED" ? "Reviewed by admin" : "Rejected by admin",
        status,
      });
      await loadAllData();
    } catch (err) {
      setError(err.message || "Failed to review video");
    }
  }

  async function handleCreateAssessment(videoId) {
    if (!adminId) return;
    try {
      await api.createAssessment(adminId, videoId, {
        overallScore: 7.5,
        skillScores: { consistency: 7.0, control: 8.0 },
        performanceLevel: "PROMISING",
        strengths: "Good control and confidence",
        areasToImprove: "Needs better stamina",
        recommendations: "Increase conditioning training",
      });
      await loadAllData();
    } catch (err) {
      setError(err.message || "Failed to create assessment");
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
    const athleteId =
      reg?.athlete?.id ??
      reg?.athleteId ??
      reg?.athlete_id ??
      reg?.athleteID;
    const eventId = reg?.event?.id ?? selectedEventId;

    if (!athleteId || !eventId) {
      setError("Cannot update registration: athlete id not returned by API");
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
      <main className="min-h-screen bg-[#080C14] text-slate-100 flex items-center justify-center">
        Loading admin data...
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-[#080C14] text-slate-100 p-6">
      <div className="max-w-7xl mx-auto">
        <div className="flex items-center justify-between mb-6">
          <div>
            <p className="text-cyan-400 text-xs font-mono tracking-widest uppercase">Admin Portal</p>
            <h1 className="text-3xl font-black">Welcome {admin?.fullName || "Admin"}</h1>
          </div>
          <button
            onClick={() => {
              localStorage.removeItem("sportyx_admin");
              navigate("/login");
            }}
            className="px-4 py-2 border border-white/20 rounded-lg"
          >
            Logout
          </button>
        </div>

        <div className="flex gap-2 mb-6">
          {tabs.map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`px-4 py-2 rounded-lg border ${
                activeTab === tab
                  ? "bg-cyan-500 text-[#080C14] border-cyan-500"
                  : "border-white/20 text-slate-300"
              }`}
            >
              {tab}
            </button>
          ))}
        </div>

        {error ? <p className="text-red-400 mb-4">{error}</p> : null}

        {activeTab === "Managers" ? (
          <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {managers.map((manager) => (
              <article key={manager.id} className="rounded-xl border border-white/10 bg-white/[0.03] p-4">
                <h3 className="font-semibold">{manager.fullName}</h3>
                <p className="text-sm text-slate-400">{manager.email}</p>
                <p className="text-sm text-slate-400">{manager.organization || "No organization"}</p>
              </article>
            ))}
          </section>
        ) : null}

        {activeTab === "Events" ? (
          <section className="space-y-6">
            <form onSubmit={handleCreateEvent} className="rounded-xl border border-white/10 bg-white/[0.03] p-4 grid gap-3">
              <h2 className="text-lg font-semibold">Create Event</h2>
              <input value={eventForm.title} onChange={(e) => setEventForm((s) => ({ ...s, title: e.target.value }))} placeholder="Title" required className="rounded-lg bg-[#0e1524] border border-white/10 px-3 py-2" />
              <textarea value={eventForm.description} onChange={(e) => setEventForm((s) => ({ ...s, description: e.target.value }))} placeholder="Description" className="rounded-lg bg-[#0e1524] border border-white/10 px-3 py-2" />
              <input value={eventForm.sportCategory} onChange={(e) => setEventForm((s) => ({ ...s, sportCategory: e.target.value }))} placeholder="Sport Category" className="rounded-lg bg-[#0e1524] border border-white/10 px-3 py-2" />
              <select value={eventForm.skillLevelRequired} onChange={(e) => setEventForm((s) => ({ ...s, skillLevelRequired: e.target.value }))} className="rounded-lg bg-[#0e1524] border border-white/10 px-3 py-2">
                <option value="BEGINNER">BEGINNER</option>
                <option value="INTERMEDIATE">INTERMEDIATE</option>
                <option value="ADVANCED">ADVANCED</option>
              </select>
              <input value={eventForm.location} onChange={(e) => setEventForm((s) => ({ ...s, location: e.target.value }))} placeholder="Location" className="rounded-lg bg-[#0e1524] border border-white/10 px-3 py-2" />
              <input type="date" value={eventForm.eventDate} onChange={(e) => setEventForm((s) => ({ ...s, eventDate: e.target.value }))} className="rounded-lg bg-[#0e1524] border border-white/10 px-3 py-2" />
              <input type="date" value={eventForm.registrationDeadline} onChange={(e) => setEventForm((s) => ({ ...s, registrationDeadline: e.target.value }))} className="rounded-lg bg-[#0e1524] border border-white/10 px-3 py-2" />
              <div>
                <label className="block text-sm text-slate-300 mb-2">Event Poster</label>
                <input type="file" accept="image/*" onChange={handlePosterChange} className="rounded-lg bg-[#0e1524] border border-white/10 px-3 py-2 w-full text-slate-300 file:bg-cyan-500 file:text-[#080C14] file:border-0 file:rounded-lg file:px-3 file:py-2 file:font-semibold file:cursor-pointer" />
                {posterPreview && (
                  <div className="mt-3">
                    <img src={posterPreview} alt="Poster preview" className="w-full h-48 object-cover rounded-lg border border-white/10" />
                  </div>
                )}
              </div>
              <button type="submit" className="px-4 py-2 bg-cyan-500 text-[#080C14] font-bold rounded-lg">Create Event</button>
            </form>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {events.map((item) => (
                <article
                  key={item.id}
                  role="button"
                  onClick={() => {
                    setSelectedEventId(item.id);
                    loadRegistrations(item.id);
                  }}
                  className="rounded-xl border border-white/10 bg-white/[0.03] p-4 cursor-pointer hover:border-cyan-500/30"
                  style={
                    selectedEventId === item.id ? { borderColor: "rgb(34 211 238 / 0.7)" } : undefined
                  }
                >
                  {item.posterUrl && (
                    <img src={item.posterUrl} alt={item.title} className="w-full h-40 object-cover rounded-lg mb-3 border border-white/10" />
                  )}
                  <h3 className="font-semibold">{item.title}</h3>
                  <p className="text-sm text-slate-400">{item.sportCategory}</p>
                  <p className="text-sm text-slate-400">{item.location}</p>
                </article>
              ))}
            </div>

            {selectedEventId ? (
              <section className="rounded-xl border border-white/10 bg-white/[0.03] p-4 space-y-3">
                <h2 className="text-lg font-semibold">Registrations</h2>
                {registrationsLoading ? (
                  <p className="text-slate-300">Loading registrations...</p>
                ) : eventRegistrations.length === 0 ? (
                  <p className="text-slate-400">No registrations yet for this event.</p>
                ) : (
                  <div className="space-y-2">
                    {eventRegistrations.map((reg) => {
                      const athleteName = reg?.athlete?.fullName || reg?.athlete?.full_name || "Athlete";
                      const status = reg?.registrationStatus || reg?.registration_status || "REGISTERED";
                      return (
                        <article key={reg.id} className="rounded-lg border border-white/10 bg-[#0e1524] p-3">
                          <div className="flex items-center justify-between gap-3">
                            <div>
                              <p className="font-semibold">{athleteName}</p>
                              <p className="text-sm text-slate-400">Status: {status}</p>
                            </div>
                            <div className="flex gap-2 flex-wrap justify-end">
                              <button
                                onClick={() => handleUpdateRegistration(reg, "SELECTED")}
                                className="px-3 py-2 bg-cyan-500 text-[#080C14] rounded-lg text-sm font-semibold"
                              >
                                Select
                              </button>
                              <button
                                onClick={() => handleUpdateRegistration(reg, "REJECTED")}
                                className="px-3 py-2 border border-red-400 text-red-300 rounded-lg text-sm font-semibold"
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
              </section>
            ) : null}
          </section>
        ) : null}

        {activeTab === "Pending Videos" ? (
          <section className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {pendingVideos.map((video) => (
              <article key={video.id} className="rounded-xl border border-white/10 bg-white/[0.03] p-4">
                <h3 className="font-semibold">{video.title || "Untitled Video"}</h3>
                <p className="text-sm text-slate-400">{video.sportCategory || "General"}</p>
                {video.videoUrl ? (
                  <video
                    controls
                    className="w-full rounded-lg mt-3 border border-white/10"
                    src={video.videoUrl}
                  />
                ) : null}
                <div className="flex gap-2 mt-3">
                  <button onClick={() => handleReview(video.id, "REVIEWED")} className="px-3 py-2 bg-cyan-500 text-[#080C14] rounded-lg text-sm font-semibold">Approve</button>
                  <button onClick={() => handleReview(video.id, "REJECTED")} className="px-3 py-2 border border-red-400 text-red-300 rounded-lg text-sm font-semibold">Reject</button>
                  <button onClick={() => handleCreateAssessment(video.id)} className="px-3 py-2 border border-white/20 rounded-lg text-sm">Add Assessment</button>
                </div>
              </article>
            ))}
          </section>
        ) : null}
      </div>
    </main>
  );
}
