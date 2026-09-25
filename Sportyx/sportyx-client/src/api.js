const API_BASE = import.meta.env.VITE_API_BASE_URL || "http://localhost:8080";

async function request(path, options = {}) {
  const response = await fetch(`${API_BASE}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    ...options,
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`Request failed (${response.status}): ${text}`);
  }

  if (response.status === 204) {
    return null;
  }
  return response.json();
}

export const api = {
  getAdmins: () => request("/api/admin/users"),
  getManagers: () => request("/api/managers"),
  getEvents: () => request("/api/events"),
  getEventRegistrations: (eventId) =>
    request(`/api/events/${eventId}/registrations`),
  createEvent: (adminId, payload) =>
    request(`/api/admin/${adminId}/events`, {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  getPendingVideos: () => request("/api/admin/videos/pending"),
  reviewVideo: (videoId, payload) =>
    request(`/api/admin/videos/${videoId}/review`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  createAssessment: (adminId, videoId, payload) =>
    request(`/api/admin/${adminId}/videos/${videoId}/assessment`, {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  updateAthleteRegistrationStatus: (athleteId, eventId, status) =>
    request(`/api/athletes/${athleteId}/events/${eventId}/status`, {
      method: "PATCH",
      body: JSON.stringify({ status }),
    }),
  uploadEventPoster: (eventId, file) => {
    const formData = new FormData();
    formData.append("posterImage", file);
    return fetch(`${API_BASE}/api/events/${eventId}/poster`, {
      method: "POST",
      body: formData,
    }).then((res) => {
      if (!res.ok) throw new Error("Failed to upload poster");
      return res.json();
    });
  },
};
