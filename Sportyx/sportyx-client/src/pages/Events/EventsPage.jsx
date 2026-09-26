import { useEffect, useState } from "react";
import { api } from "../../api";

export default function EventsPage() {
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selectedEvent, setSelectedEvent] = useState(null);

  useEffect(() => {
    loadEvents();
  }, []);

  async function loadEvents() {
    setLoading(true);
    setError("");
    try {
      const data = await api.getEvents();
      setEvents(data);
    } catch (err) {
      setError(err.message || "Failed to load events");
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <main className="min-h-screen bg-[#080C14] text-slate-100">
        <div className="max-w-7xl mx-auto p-6">
          <p className="text-center">Loading events...</p>
        </div>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-[#080C14] text-slate-100">
      {/* Header */}
      <header className="border-b border-white/10 bg-gradient-to-r from-cyan-500/10 to-blue-500/10">
        <div className="max-w-7xl mx-auto px-6 py-12">
          <p className="text-cyan-400 text-xs font-mono tracking-widest uppercase mb-2">Sports Events</p>
          <h1 className="text-4xl font-black mb-2">Upcoming Events</h1>
          <p className="text-slate-400 max-w-2xl">
            Discover and register for exciting sports events. Find opportunities that match your skill level and interests.
          </p>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-6 py-12">
        {error && (
          <div className="bg-red-500/10 border border-red-500/30 rounded-lg p-4 mb-6 text-red-300">
            {error}
          </div>
        )}

        {events.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-slate-400 text-lg">No events available at the moment.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {events.map((event) => (
              <article
                key={event.id}
                onClick={() => setSelectedEvent(event)}
                className="rounded-xl border border-white/10 bg-white/[0.03] overflow-hidden hover:border-cyan-500/50 transition-colors cursor-pointer"
              >
                {/* Event Poster */}
                {event.posterUrl ? (
                  <img
                    src={event.posterUrl}
                    alt={event.title}
                    className="w-full h-48 object-cover"
                  />
                ) : (
                  <div className="w-full h-48 bg-gradient-to-br from-cyan-500/20 to-blue-500/20 flex items-center justify-center">
                    <span className="text-slate-400">No Poster</span>
                  </div>
                )}

                {/* Event Details */}
                <div className="p-4">
                  <div className="flex items-start justify-between mb-2">
                    <h3 className="text-lg font-semibold flex-1">{event.title}</h3>
                    <span className="text-xs bg-cyan-500/20 text-cyan-300 px-2 py-1 rounded">
                      {event.skillLevelRequired}
                    </span>
                  </div>

                  <p className="text-sm text-slate-400 mb-3">{event.description || "No description"}</p>

                  <div className="space-y-2 text-sm text-slate-400">
                    <p>
                      <span className="text-cyan-400">Sport:</span> {event.sportCategory}
                    </p>
                    <p>
                      <span className="text-cyan-400">Location:</span> {event.location}
                    </p>
                    <p>
                      <span className="text-cyan-400">Date:</span> {new Date(event.eventDate).toLocaleDateString()}
                    </p>
                    <p>
                      <span className="text-cyan-400">Deadline:</span> {new Date(event.registrationDeadline).toLocaleDateString()}
                    </p>
                  </div>

                  <button
                    onClick={() => setSelectedEvent(event)}
                    className="mt-4 w-full px-3 py-2 bg-cyan-500 text-[#080C14] rounded-lg font-semibold text-sm hover:bg-cyan-400 transition-colors"
                  >
                    View Details
                  </button>
                </div>
              </article>
            ))}
          </div>
        )}
      </div>

      {/* Event Detail Modal */}
      {selectedEvent && (
        <div
          className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4"
          onClick={() => setSelectedEvent(null)}
        >
          <article
            onClick={(e) => e.stopPropagation()}
            className="rounded-xl border border-white/10 bg-[#0a0f1a] max-w-2xl w-full max-h-[90vh] overflow-y-auto"
          >
            {/* Modal Header with Poster */}
            {selectedEvent.posterUrl && (
              <img
                src={selectedEvent.posterUrl}
                alt={selectedEvent.title}
                className="w-full h-64 object-cover"
              />
            )}

            <div className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h2 className="text-2xl font-bold mb-2">{selectedEvent.title}</h2>
                  <div className="flex gap-2">
                    <span className="text-xs bg-cyan-500/20 text-cyan-300 px-2 py-1 rounded">
                      {selectedEvent.skillLevelRequired}
                    </span>
                    <span className="text-xs bg-blue-500/20 text-blue-300 px-2 py-1 rounded">
                      {selectedEvent.sportCategory}
                    </span>
                  </div>
                </div>
                <button
                  onClick={() => setSelectedEvent(null)}
                  className="text-slate-400 hover:text-slate-200 text-2xl"
                >
                  ×
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <h3 className="text-cyan-400 font-semibold mb-2">Description</h3>
                  <p className="text-slate-300">{selectedEvent.description || "No description available"}</p>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-cyan-400 font-semibold">Location</p>
                    <p className="text-slate-300">{selectedEvent.location}</p>
                  </div>
                  <div>
                    <p className="text-cyan-400 font-semibold">Event Date</p>
                    <p className="text-slate-300">
                      {new Date(selectedEvent.eventDate).toLocaleDateString()}
                    </p>
                  </div>
                  <div>
                    <p className="text-cyan-400 font-semibold">Registration Deadline</p>
                    <p className="text-slate-300">
                      {new Date(selectedEvent.registrationDeadline).toLocaleDateString()}
                    </p>
                  </div>
                  <div>
                    <p className="text-cyan-400 font-semibold">Skill Level</p>
                    <p className="text-slate-300">{selectedEvent.skillLevelRequired}</p>
                  </div>
                </div>

                <div className="flex gap-3 pt-4 border-t border-white/10">
                  <button className="flex-1 px-4 py-2 bg-cyan-500 text-[#080C14] rounded-lg font-semibold hover:bg-cyan-400 transition-colors">
                    Register Now
                  </button>
                  <button
                    onClick={() => setSelectedEvent(null)}
                    className="flex-1 px-4 py-2 border border-white/20 text-slate-300 rounded-lg font-semibold hover:border-white/40 transition-colors"
                  >
                    Close
                  </button>
                </div>
              </div>
            </div>
          </article>
        </div>
      )}
    </main>
  );
}
