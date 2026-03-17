// src/App.jsx or your router file
import { BrowserRouter, Routes, Route } from "react-router-dom";
import LandingPage from "./pages/Landing/LandingPage";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        {/* <Route path="/login" element={<AdminLogin />} /> */}
      </Routes>
    </BrowserRouter>
  );
}