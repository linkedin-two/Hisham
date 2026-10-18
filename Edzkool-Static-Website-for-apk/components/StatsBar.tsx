import React from "react";

export default function StatsBar() {
  const stats = [
    { number: "1 – 12", label: "Grades covered" },
    { number: "Live", label: "Interactive online classes" },
    { number: "4 tracks", label: "Tuition, coding, languages and certificates" },
    { number: "Free", label: "Demo class to start" },
  ];

  return (
    <section className="bg-[#144787] text-white">
      <div className="max-w-[1200px] mx-auto px-6 py-9 grid grid-cols-2 lg:grid-cols-4 gap-7 md:gap-9">
        {stats.map((s, idx) => (
          <div key={idx} className="flex flex-col">
            <div className="font-serif text-3xl sm:text-4xl font-bold text-[#FFB84D] tracking-tight">
              {s.number}
            </div>
            <div className="text-[15px] opacity-90 mt-1 font-medium text-white/90">
              {s.label}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
