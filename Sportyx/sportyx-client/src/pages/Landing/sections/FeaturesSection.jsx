import { motion } from "framer-motion";

const features = [
  {
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5" />
      </svg>
    ),
    label: "Event Management",
    description:
      "Schedule, coordinate, and oversee sports events from creation to completion. Assign roles, set venues, and track logistics with precision.",
    accent: "from-cyan-500 to-cyan-400",
    glow: "group-hover:shadow-[0_0_40px_rgba(0,229,255,0.12)]",
    border: "group-hover:border-cyan-500/40",
  },
  {
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
      </svg>
    ),
    label: "Player Analytics",
    description:
      "Deep-dive into individual and team performance metrics. Track growth trajectories, compare benchmarks, and identify potential.",
    accent: "from-blue-500 to-blue-400",
    glow: "group-hover:shadow-[0_0_40px_rgba(59,130,246,0.12)]",
    border: "group-hover:border-blue-500/40",
  },
  {
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 013 19.875v-6.75zM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V8.625zM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V4.125z" />
      </svg>
    ),
    label: "Performance Insights",
    description:
      "AI-assisted reporting surfaces patterns in real time. Turn raw data into strategic decisions that keep your organization ahead.",
    accent: "from-indigo-500 to-indigo-400",
    glow: "group-hover:shadow-[0_0_40px_rgba(99,102,241,0.12)]",
    border: "group-hover:border-indigo-500/40",
  },
];

const cardVariants = {
  hidden: { opacity: 0, y: 40 },
  visible: (i) => ({
    opacity: 1,
    y: 0,
    transition: { duration: 0.55, delay: i * 0.12, ease: "easeOut" },
  }),
};

export default function FeaturesSection() {
  return (
    <section id="features" className="bg-[#080C14] py-28 relative overflow-hidden">
      {/* Subtle separator line */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-px h-16 bg-gradient-to-b from-transparent to-cyan-500/30" />

      <div className="max-w-7xl mx-auto px-6 lg:px-12">
        {/* Heading */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.55 }}
          className="mb-16 max-w-xl"
        >
          <p className="text-cyan-400 text-xs font-mono tracking-widest uppercase mb-3">
            Platform Capabilities
          </p>
          <h2
            className="text-4xl lg:text-5xl font-black text-white leading-tight"
            style={{ fontFamily: "'Bebas Neue', sans-serif", letterSpacing: "0.03em" }}
          >
            Built for sports<br />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-blue-500">
              at every level
            </span>
          </h2>
        </motion.div>

        {/* Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {features.map((feat, i) => (
            <motion.div
              key={feat.label}
              custom={i}
              variants={cardVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true }}
              className={`group relative rounded-xl border border-white/5 bg-white/[0.03] backdrop-blur-sm p-8 transition-all duration-500 cursor-default ${feat.glow} ${feat.border}`}
            >
              {/* Top accent line */}
              <div className={`absolute top-0 left-8 right-8 h-px bg-gradient-to-r ${feat.accent} opacity-0 group-hover:opacity-100 transition-opacity duration-500`} />

              {/* Icon */}
              <div className={`mb-6 w-12 h-12 rounded-lg bg-gradient-to-br ${feat.accent} bg-opacity-10 flex items-center justify-center text-white`}
                style={{ background: "rgba(255,255,255,0.04)" }}
              >
                <span className={`bg-gradient-to-br ${feat.accent} bg-clip-text text-transparent`}>
                  {feat.icon}
                </span>
              </div>

              <h3
                className="text-white text-lg font-bold mb-3 tracking-wide"
                style={{ fontFamily: "'Barlow Condensed', sans-serif", fontSize: "1.2rem" }}
              >
                {feat.label}
              </h3>
              <p className="text-slate-400 text-sm leading-relaxed">{feat.description}</p>

              {/* Bottom arrow on hover */}
              <div className="mt-6 flex items-center gap-1.5 text-slate-600 group-hover:text-cyan-400 transition-colors duration-300 text-xs tracking-wider font-mono uppercase">
                <span>Explore</span>
                <svg className="w-3 h-3 translate-x-0 group-hover:translate-x-1 transition-transform duration-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
                </svg>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}