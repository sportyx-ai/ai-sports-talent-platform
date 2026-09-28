import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import AdminHeader from "../../components/AdminHeader";
import { api } from "../../api";

export default function AdminVideos() {
  const navigate = useNavigate();
  const [admin, setAdmin] = useState(null);
  const [videos, setVideos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [filter, setFilter] = useState("PENDING");

  useEffect(() => {
    const raw = localStorage.getItem("sportyx_admin");
    if (!raw) {
      navigate("/login");
      return;
    }
    const parsed = JSON.parse(raw);
    setAdmin(parsed);
    loadVideos();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [navigate]);

  async function loadVideos() {
    setLoading(true);
    setError("");
    try {
      const videoData = await api.getPendingVideos();
      setVideos(videoData);
    } catch (err) {
      setError(err.message || "Failed to load videos");
    } finally {
      setLoading(false);
    }
  }

  async function handleReview(videoId, status, feedback = "") {
    try {
      await api.reviewVideo(videoId, {
        feedback: feedback || (status === "REVIEWED" ? "Approved by admin" : "Rejected by admin"),
        status,
      });
      await loadVideos();
    } catch (err) {
      setError(err.message || "Failed to review video");
    }
  }

  async function handleCreateAssessment(videoId) {
    if (!admin?.id) return;
    try {
      await api.createAssessment(admin.id, videoId, {
        overallScore: 7.5,
        skillScores: { consistency: 7.0, control: 8.0 },
        performanceLevel: "PROMISING",
        strengths: "Good control and confidence",
        areasToImprove: "Needs better stamina",
        recommendations: "Increase conditioning training",
      });
      await loadVideos();
    } catch (err) {
      setError(err.message || "Failed to create assessment");
    }
  }

  const statuses = {
    PENDING: videos.filter((v) => v.adminReviewStatus === "PENDING").length,
    REVIEWED: videos.filter((v) => v.adminReviewStatus === "REVIEWED").length,
    REJECTED: videos.filter((v) => v.adminReviewStatus === "REJECTED").length,
  };

  const filteredVideos = videos.filter((v) => {
    if (filter === "PENDING") return v.adminReviewStatus === "PENDING";
    if (filter === "REVIEWED") return v.adminReviewStatus === "REVIEWED";
    if (filter === "REJECTED") return v.adminReviewStatus === "REJECTED";
    return true;
  });

  if (loading) {
    return (
      <main className="min-h-screen bg-gradient-to-br from-[#080C14] via-[#0a1428] to-[#080C14] text-slate-100">
        <AdminHeader admin={admin} />
        <div className="max-w-7xl mx-auto px-6 py-12 text-center">
          <div className="animate-spin text-5xl mb-4">⚙️</div>
          <p className="text-slate-400">Loading videos...</p>
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
            <div className="absolute inset-0 bg-gradient-to-r from-purple-500/20 to-pink-500/20 blur-xl rounded-2xl"></div>
            <div className="relative bg-gradient-to-r from-purple-500/10 to-pink-500/10 border border-purple-500/30 rounded-2xl p-8">
              <p className="text-purple-400 text-sm font-mono tracking-widest uppercase mb-2">Quality Control</p>
              <h1 className="text-4xl font-black mb-2">Video Approvals</h1>
              <p className="text-slate-300">Review and approve athlete performance videos</p>
            </div>
          </div>
        </div>

        {error && (
          <div className="bg-red-500/10 border border-red-500/30 rounded-xl p-4 mb-6 text-red-300 flex items-center gap-3">
            <span className="text-xl">✕</span> {error}
          </div>
        )}

        {/* Filter Buttons */}
        <div className="flex gap-3 mb-8 flex-wrap">
          {[
            { key: "PENDING", label: "⏳ Pending", count: statuses.PENDING },
            { key: "REVIEWED", label: "✓ Approved", count: statuses.REVIEWED },
            { key: "REJECTED", label: "✕ Rejected", count: statuses.REJECTED },
            { key: "ALL", label: "📊 All", count: videos.length },
          ].map((btn) => (
            <button
              key={btn.key}
              onClick={() => setFilter(btn.key)}
              className={`px-6 py-3 rounded-lg border font-semibold transition-all flex items-center gap-2 ${
                filter === btn.key
                  ? "bg-gradient-to-r from-cyan-500 to-blue-600 text-[#080C14] border-transparent shadow-lg shadow-cyan-500/30"
                  : "border-white/20 text-slate-300 hover:border-white/40 hover:bg-white/5"
              }`}
            >
              <span>{btn.label.split(" ")[0]}</span>
              <span className="text-sm">{btn.label.split(" ")[1]}</span>
              <span className="bg-white/20 px-2 py-0.5 rounded text-xs font-bold">
                {btn.count}
              </span>
            </button>
          ))}
        </div>

        {/* Videos Grid */}
        {filteredVideos.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-white/20 bg-white/[0.02] p-16 text-center">
            <p className="text-5xl mb-4">🎬</p>
            <p className="text-slate-400 text-lg">No videos to display</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredVideos.map((video) => {
              const athleteName = video?.athlete?.fullName || video?.athlete?.full_name || "Unknown";
              const status = video?.adminReviewStatus || "PENDING";

              const statusConfig = {
                PENDING: { icon: "⏳", color: "amber", label: "Pending Review" },
                REVIEWED: { icon: "✓", color: "green", label: "Approved" },
                REJECTED: { icon: "✕", color: "red", label: "Rejected" },
              };

              const config = statusConfig[status] || statusConfig.PENDING;

              return (
                <div
                  key={video.id}
                  className="group rounded-2xl border border-white/10 bg-white/[0.02] overflow-hidden hover:border-white/20 hover:shadow-lg transition-all"
                >
                  {/* Video Thumbnail */}
                  {video.videoUrl ? (
                    <div className="relative h-48 bg-black overflow-hidden">
                      <video
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                        src={video.videoUrl}
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
                      <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                        <div className="text-4xl">▶️</div>
                      </div>
                    </div>
                  ) : (
                    <div className="h-48 bg-slate-800 flex items-center justify-center">
                      <span className="text-slate-500 text-4xl">📹</span>
                    </div>
                  )}

                  {/* Video Info */}
                  <div className="p-5">
                    <div className="mb-3">
                      <div className="flex items-start justify-between gap-2 mb-2">
                        <p className="font-bold text-cyan-400 text-sm line-clamp-2">{video.title || "Untitled"}</p>
                        <span className={`text-xs px-2 py-1 rounded-full whitespace-nowrap font-semibold flex items-center gap-1 ${
                          status === "PENDING" ? "bg-amber-500/20 text-amber-300" :
                          status === "REVIEWED" ? "bg-green-500/20 text-green-300" :
                          "bg-red-500/20 text-red-300"
                        }`}>
                          <span>{config.icon}</span>
                          {config.label}
                        </span>
                      </div>

                      <p className="text-xs text-slate-500">{athleteName}</p>
                      <div className="flex items-center gap-2 mt-2">
                        <span className="text-xs bg-blue-500/20 text-blue-300 px-2 py-1 rounded">
                          🏆 {video.sportCategory || "General"}
                        </span>
                      </div>
                    </div>

                    {video.adminFeedback && (
                      <div className="mb-3 p-3 bg-slate-800/50 rounded-lg text-xs text-slate-300">
                        <p className="text-cyan-400 font-semibold mb-1">Feedback:</p>
                        <p className="line-clamp-2">{video.adminFeedback}</p>
                      </div>
                    )}

                    {/* Action Buttons */}
                    <div className="space-y-2">
                      {status === "PENDING" && (
                        <div className="flex gap-2">
                          <button
                            onClick={() => handleReview(video.id, "REVIEWED", "Approved")}
                            className="flex-1 px-3 py-2 bg-green-500/30 border border-green-500/50 text-green-300 rounded-lg text-xs font-semibold hover:bg-green-500/50 transition-colors"
                          >
                            ✓ Approve
                          </button>
                          <button
                            onClick={() => handleReview(video.id, "REJECTED", "Rejected")}
                            className="flex-1 px-3 py-2 bg-red-500/30 border border-red-500/50 text-red-300 rounded-lg text-xs font-semibold hover:bg-red-500/50 transition-colors"
                          >
                            ✕ Reject
                          </button>
                        </div>
                      )}

                      {status === "REVIEWED" && (
                        <button
                          onClick={() => handleCreateAssessment(video.id)}
                          className="w-full px-3 py-2 border border-cyan-500/50 text-cyan-300 rounded-lg text-xs font-semibold hover:bg-cyan-500/30 transition-colors"
                        >
                          + Add Assessment
                        </button>
                      )}

                      {status !== "PENDING" && (
                        <button
                          onClick={() => handleReview(video.id, "PENDING", "Reopened")}
                          className="w-full px-3 py-2 border border-white/20 text-slate-300 rounded-lg text-xs font-semibold hover:border-white/40 hover:bg-white/5 transition-colors"
                        >
                          🔄 Reopen
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </main>
  );
}
