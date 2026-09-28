import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import AdminHeader from "../../components/AdminHeader";
import { api } from "../../api";

export default function AdminCreateEvent() {
  const navigate = useNavigate();
  const [admin, setAdmin] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [posterPreview, setPosterPreview] = useState(null);
  const [formStep, setFormStep] = useState(1);

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

  const adminId = useMemo(() => admin?.id, [admin]);

  useEffect(() => {
    const raw = localStorage.getItem("sportyx_admin");
    if (!raw) {
      navigate("/login");
      return;
    }
    const parsed = JSON.parse(raw);
    setAdmin(parsed);

    api.getAdmins().then((admins) => {
      if (admins && admins.length > 0) {
        const found = admins.find((a) => a.email === parsed.email) || admins[0];
        if (found && found.id !== parsed.id) {
          localStorage.setItem("sportyx_admin", JSON.stringify(found));
          setAdmin(found);
        }
      }
    }).catch(() => {});
  }, [navigate]);

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

  async function handleCreateEvent(evt) {
    evt.preventDefault();
    if (!adminId) return;

    setLoading(true);
    setError("");
    setSuccess("");

    try {
      const eventData = { ...eventForm };
      delete eventData.posterFile;

      const createdEvent = await api.createEvent(adminId, eventData);

      if (eventForm.posterFile) {
        await api.uploadEventPoster(createdEvent.id, eventForm.posterFile);
      }

      setSuccess("Event created successfully!");

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
      setFormStep(1);

      setTimeout(() => {
        navigate("/admin/events");
      }, 2000);
    } catch (err) {
      setError(err.message || "Failed to create event");
    } finally {
      setLoading(false);
    }
  }

  const isFormValid = () => {
    return (
      eventForm.title.trim() &&
      eventForm.sportCategory.trim() &&
      eventForm.location.trim() &&
      eventForm.eventDate &&
      eventForm.registrationDeadline
    );
  };

  return (
    <main className="min-h-screen bg-gradient-to-br from-[#080C14] via-[#0a1428] to-[#080C14] text-slate-100">
      <AdminHeader admin={admin} />

      <div className="max-w-5xl mx-auto px-6 py-12">
        {/* Hero Section */}
        <div className="mb-12">
          <div className="relative">
            <div className="absolute inset-0 bg-gradient-to-r from-cyan-500/20 to-blue-500/20 blur-xl rounded-2xl"></div>
            <div className="relative bg-gradient-to-r from-cyan-500/10 to-blue-500/10 border border-cyan-500/30 rounded-2xl p-8">
              <p className="text-cyan-400 text-sm font-mono tracking-widest uppercase mb-2">Event Management</p>
              <h1 className="text-4xl font-black mb-2">Create New Event</h1>
              <p className="text-slate-300">Add a new sports event with poster and complete details</p>
            </div>
          </div>
        </div>

        {error && (
          <div className="bg-red-500/10 border border-red-500/30 rounded-xl p-4 mb-6 text-red-300 flex items-center gap-3">
            <span className="text-xl">✕</span> {error}
          </div>
        )}

        {success && (
          <div className="bg-green-500/10 border border-green-500/30 rounded-xl p-4 mb-6 text-green-300 flex items-center gap-3">
            <span className="text-xl">✓</span> {success}
          </div>
        )}

        <form onSubmit={handleCreateEvent} className="space-y-8">
          {/* Step 1: Basic Info */}
          <div className="rounded-2xl border border-white/10 bg-white/[0.02] backdrop-blur-sm p-8 hover:border-white/20 transition-colors">
            <div className="flex items-center gap-3 mb-6">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm ${
                formStep >= 1 ? "bg-cyan-500 text-[#080C14]" : "bg-white/10 text-slate-400"
              }`}>
                1
              </div>
              <h2 className="text-xl font-bold">Event Overview</h2>
            </div>

            <div className="space-y-5">
              <div>
                <label className="block text-sm font-semibold text-slate-300 mb-2">
                  Event Title *
                </label>
                <input
                  type="text"
                  required
                  value={eventForm.title}
                  onChange={(e) => setEventForm((s) => ({ ...s, title: e.target.value }))}
                  placeholder="e.g., National Basketball Championship 2024"
                  className="w-full rounded-lg bg-white/[0.05] border border-white/10 px-4 py-3 text-slate-100 placeholder-slate-600 focus:border-cyan-500 focus:bg-white/[0.08] focus:outline-none transition-all"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-slate-300 mb-2">
                  Description
                </label>
                <textarea
                  rows="4"
                  value={eventForm.description}
                  onChange={(e) => setEventForm((s) => ({ ...s, description: e.target.value }))}
                  placeholder="Describe the event, objectives, highlights, and key details..."
                  className="w-full rounded-lg bg-white/[0.05] border border-white/10 px-4 py-3 text-slate-100 placeholder-slate-600 focus:border-cyan-500 focus:bg-white/[0.08] focus:outline-none transition-all resize-none"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div>
                  <label className="block text-sm font-semibold text-slate-300 mb-2">
                    Sport Category *
                  </label>
                  <input
                    type="text"
                    required
                    value={eventForm.sportCategory}
                    onChange={(e) => setEventForm((s) => ({ ...s, sportCategory: e.target.value }))}
                    placeholder="e.g., Basketball, Football, Tennis"
                    className="w-full rounded-lg bg-white/[0.05] border border-white/10 px-4 py-3 text-slate-100 placeholder-slate-600 focus:border-cyan-500 focus:bg-white/[0.08] focus:outline-none transition-all"
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-300 mb-2">
                    Skill Level
                  </label>
                  <select
                    value={eventForm.skillLevelRequired}
                    onChange={(e) => setEventForm((s) => ({ ...s, skillLevelRequired: e.target.value }))}
                    className="w-full rounded-lg bg-white/[0.05] border border-white/10 px-4 py-3 text-slate-100 focus:border-cyan-500 focus:bg-white/[0.08] focus:outline-none transition-all appearance-none cursor-pointer"
                    style={{
                      backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%2306b6d4'%3E%3Cpath d='M7 10l5 5 5-5z'/%3E%3C/svg%3E")`,
                      backgroundRepeat: 'no-repeat',
                      backgroundPosition: 'right 12px center',
                      backgroundSize: '20px',
                      paddingRight: '40px'
                    }}
                  >
                    <option value="BEGINNER">🟢 Beginner</option>
                    <option value="INTERMEDIATE">🟡 Intermediate</option>
                    <option value="ADVANCED">🔴 Advanced</option>
                  </select>
                </div>
              </div>
            </div>
          </div>

          {/* Step 2: Location & Dates */}
          <div className="rounded-2xl border border-white/10 bg-white/[0.02] backdrop-blur-sm p-8 hover:border-white/20 transition-colors">
            <div className="flex items-center gap-3 mb-6">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm ${
                formStep >= 2 && eventForm.title ? "bg-cyan-500 text-[#080C14]" : "bg-white/10 text-slate-400"
              }`}>
                2
              </div>
              <h2 className="text-xl font-bold">Location & Schedule</h2>
            </div>

            <div className="space-y-5">
              <div>
                <label className="block text-sm font-semibold text-slate-300 mb-2">
                  📍 Location *
                </label>
                <input
                  type="text"
                  required
                  value={eventForm.location}
                  onChange={(e) => setEventForm((s) => ({ ...s, location: e.target.value }))}
                  placeholder="e.g., Madison Square Garden, New York, NY"
                  className="w-full rounded-lg bg-white/[0.05] border border-white/10 px-4 py-3 text-slate-100 placeholder-slate-600 focus:border-cyan-500 focus:bg-white/[0.08] focus:outline-none transition-all"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div>
                  <label className="block text-sm font-semibold text-slate-300 mb-2">
                    📅 Event Date *
                  </label>
                  <input
                    type="date"
                    required
                    value={eventForm.eventDate}
                    onChange={(e) => setEventForm((s) => ({ ...s, eventDate: e.target.value }))}
                    className="w-full rounded-lg bg-white/[0.05] border border-white/10 px-4 py-3 text-slate-100 focus:border-cyan-500 focus:bg-white/[0.08] focus:outline-none transition-all"
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-300 mb-2">
                    ⏰ Registration Deadline *
                  </label>
                  <input
                    type="date"
                    required
                    value={eventForm.registrationDeadline}
                    onChange={(e) => setEventForm((s) => ({ ...s, registrationDeadline: e.target.value }))}
                    className="w-full rounded-lg bg-white/[0.05] border border-white/10 px-4 py-3 text-slate-100 focus:border-cyan-500 focus:bg-white/[0.08] focus:outline-none transition-all"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Step 3: Event Poster */}
          <div className="rounded-2xl border border-white/10 bg-white/[0.02] backdrop-blur-sm p-8 hover:border-white/20 transition-colors">
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm bg-white/10 text-slate-400">
                3
              </div>
              <h2 className="text-xl font-bold">Event Poster</h2>
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-300 mb-4">
                🖼️ Upload Poster Image
              </label>
              <div className="flex gap-6 items-start">
                {/* Upload Area */}
                <div className="flex-1">
                  <label className="relative block">
                    <div className="border-2 border-dashed border-cyan-500/30 rounded-xl p-8 text-center hover:border-cyan-500/50 hover:bg-cyan-500/5 transition-all cursor-pointer group">
                      <input
                        type="file"
                        accept="image/*"
                        onChange={handlePosterChange}
                        className="hidden"
                      />
                      <div className="group-hover:scale-110 transition-transform">
                        <p className="text-3xl mb-2">🖼️</p>
                        <p className="text-slate-300 font-semibold mb-1">
                          {posterPreview ? "Change Poster" : "Click to upload"}
                        </p>
                        <p className="text-xs text-slate-500">
                          {posterPreview ? "Select a new image" : "PNG, JPG, GIF up to 10MB"}
                        </p>
                      </div>
                    </div>
                  </label>
                  <p className="text-xs text-slate-500 mt-2">Recommended: 1200x800px or higher</p>
                </div>

                {/* Preview */}
                {posterPreview && (
                  <div className="flex-1">
                    <div className="relative">
                      <img
                        src={posterPreview}
                        alt="Poster preview"
                        className="w-full h-64 object-cover rounded-xl border border-cyan-500/30"
                      />
                      <button
                        type="button"
                        onClick={() => {
                          setPosterPreview(null);
                          setEventForm((s) => ({ ...s, posterFile: null }));
                        }}
                        className="absolute top-2 right-2 bg-red-500 hover:bg-red-600 text-white p-2 rounded-lg transition-colors"
                      >
                        ✕
                      </button>
                    </div>
                    <p className="text-xs text-green-400 mt-2">✓ Poster ready</p>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Submit Button */}
          <div className="flex gap-4 pt-4">
            <button
              type="submit"
              disabled={loading || !isFormValid()}
              className="flex-1 px-6 py-4 bg-gradient-to-r from-cyan-500 to-blue-600 text-[#080C14] font-bold text-lg rounded-xl hover:from-cyan-400 hover:to-blue-500 transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-cyan-500/20"
            >
              {loading ? "Creating Event..." : "✓ Create Event"}
            </button>
            <button
              type="button"
              onClick={() => navigate("/admin/home")}
              className="flex-1 px-6 py-4 border border-white/20 text-slate-300 font-semibold text-lg rounded-xl hover:border-white/40 hover:bg-white/5 transition-all"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </main>
  );
}
