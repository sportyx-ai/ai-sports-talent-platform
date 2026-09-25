// src/App.jsx
import { BrowserRouter, Routes, Route } from "react-router-dom";
import LandingPage from "./pages/Landing/LandingPage";
import AdminLogin from "./pages/admin/AdminLogin";
import AdminHome from "./pages/admin/AdminHome";
import AdminCreateEvent from "./pages/admin/AdminCreateEvent";
import AdminEvents from "./pages/admin/AdminEvents";
import AdminApplications from "./pages/admin/AdminApplications";
import AdminVideos from "./pages/admin/AdminVideos";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Public Routes */}
        <Route path="/" element={<LandingPage />} />

        {/* Admin Routes */}
        <Route path="/login" element={<AdminLogin />} />
        <Route path="/admin/home" element={<AdminHome />} />
        <Route path="/admin/create-event" element={<AdminCreateEvent />} />
        <Route path="/admin/events" element={<AdminEvents />} />
        <Route path="/admin/applications" element={<AdminApplications />} />
        <Route path="/admin/videos" element={<AdminVideos />} />
      </Routes>
    </BrowserRouter>
  );
}
