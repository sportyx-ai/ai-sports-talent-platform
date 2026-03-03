import { motion } from "framer-motion";
import { useEffect, useRef, useState } from "react";

const stats = [
  { value: 120, suffix: "+", label: "Events Managed", description: "across all sports categories" },
  { value: 5000, suffix: "+", label: "Players Tracked", description: "individual athlete profiles" },
  { value: 98, suffix: "%", label: "Performance Accuracy", description: "in analytical reporting" },
  { value: 40, suffix: "+", label: "Competitions Hosted", description: "domestic & international" },
];

function useCountUp(target, duration = 1800, start = false) {
  const [count, setCount] = useState(0);

  useEffect(() => {
    if (!start) return;
    let startTime = null;

    const step = (timestamp) => {
      if (!startTime) startTime = timestamp;
      const progress = Math.min((timestamp - startTime) / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      setCount(Math.floor(eased * target));
      if (progress < 1) requestAnimationFrame(step);
    };

    requestAnimationFrame(step);
  }, [target, duration, start]);

  return count;
}

function StatCard({ stat, index, inView }) {
  const count = useCountUp(stat.value, 1600, inView);

  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      animate={inView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.55, delay: index * 0.1, ease: "easeOut" }}
      className="relative flex flex-col items-center text-center px-6 py-10 rounded-xl border border-white/5 bg-white/[0.02]"
    >
      {/* Glow dot */}
      <div className="absolute top-4 right-4 w-1.5 h-1.5 rounded-full bg-cyan-500/60" />

      <div
        className="text-5xl lg:text-6xl font-black text-white mb-1 tabular-nums"
        style={{ fontFamily: "'Bebas Neue', sans-serif", letterSpacing: "0.02em" }}
      >
        <span className="text-transparent bg-clip-text bg-gradient-to-b from-white to-slate-400">
          {count.toLocaleString()}
        </span>
        <span className="text-cyan-400">{stat.suffix}</span>
      </div>

      <p
        className="text-white text-sm font-semibold tracking-widest uppercase mb-1.5"
        style={{ fontFamily: "'Barlow Condensed', sans-serif" }}
      >
        {stat.label}
      </p>
      <p className="text-slate-500 text-xs">{stat.description}</p>
    </motion.div>
  );
}

export default function StatsSection() {
  const ref = useRef(null);
  const [inView, setInView] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => { if (entry.isIntersecting) setInView(true); },
      { threshold: 0.3 }
    );
    if (ref.current) observer.observe(ref.current);
    return () => observer.disconnect();
  }, []);

  return (
    <section ref={ref} className="bg-[#060A11] py-28 relative overflow-hidden">
      {/* Background accent */}
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-cyan-500/20 to-transparent" />
      <div className="absolute inset-x-0 bottom-0 h-px bg-gradient-to-r from-transparent via-cyan-500/20 to-transparent" />
      <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[300px] bg-cyan-500/5 rounded-full blur-3xl pointer-events-none" />

      <div className="max-w-7xl mx-auto px-6 lg:px-12 relative z-10">
        {/* Label */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.4 }}
          className="text-center mb-14"
        >
          <p className="text-cyan-400 text-xs font-mono tracking-widest uppercase mb-3">
            By the Numbers
          </p>
          <h2
            className="text-4xl lg:text-5xl font-black text-white"
            style={{ fontFamily: "'Bebas Neue', sans-serif", letterSpacing: "0.03em" }}
          >
            The Platform in Action
          </h2>
        </motion.div>

        {/* Stats grid */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {stats.map((stat, i) => (
            <StatCard key={stat.label} stat={stat} index={i} inView={inView} />
          ))}
        </div>
      </div>
    </section>
  );
}