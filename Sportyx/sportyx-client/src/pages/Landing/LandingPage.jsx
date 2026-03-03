import HeroSection from "./sections//HeroSection";
import FeaturesSection from "./sections/FeaturesSection";
import StatsSection from "./sections/StatsSection";
import Footer from "./sections/Footer";

export default function LandingPage() {
  return (
    <main className="min-h-screen bg-[#080C14] antialiased">
      <HeroSection />
      <FeaturesSection />
      <StatsSection />
      <Footer />
    </main>
  );
}