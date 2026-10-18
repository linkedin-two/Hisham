import React from "react";
import Link from "next/link";

export default function ClassroomFeature() {
  const perks = [
    "Live, interactive lessons, never just recordings",
    "Feedback on what to improve next, not only a grade",
    "Regular progress updates for parents",
  ];

  return (
    <section className="bg-[#0B2A5B] text-white">
      <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-wrap gap-12 lg:gap-16 items-center">
        {/* Left: Illustration */}
        <div className="flex-1 min-w-[280px] md:min-w-[420px] flex justify-center">
          <img
            src="/edzkool_new_images/home-section2.png"
            alt="A classroom where every child is seen"
            className="w-full max-w-[560px] h-auto object-contain block rounded-3xl shadow-md"
          />
        </div>

        {/* Right: Content */}
        <div className="flex-1 min-w-[280px] md:min-w-[380px] flex flex-col gap-5">
          <div className="text-[#FFB84D] font-bold text-sm tracking-widest uppercase">
            Inside a class
          </div>

          <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight font-bold tracking-tight">
            A classroom where every child is seen.
          </h2>

          <p className="text-base sm:text-[17px] leading-relaxed text-[#D6E3F6]">
            Teachers explain, check understanding and answer questions in real time, so
            doubts never pile up and confidence keeps growing.
          </p>

          <div className="flex flex-col gap-3.5 text-base font-semibold pt-1">
            {perks.map((perk, idx) => (
              <div key={idx} className="flex gap-3 items-center">
                <span className="shrink-0 w-7 h-7 rounded-full bg-[#FD9202] text-[#0B2A5B] flex items-center justify-center font-bold text-sm">
                  ✓
                </span>
                <span className="text-white/95">{perk}</span>
              </div>
            ))}
          </div>

          <div className="pt-2">
            <Link
              href="/about"
              className="inline-block bg-[#FD9202] hover:bg-[#e88500] text-[#0B2A5B] font-bold text-base px-6 py-3.5 rounded-full transition-transform transform hover:-translate-y-0.5"
            >
              Learn about our approach
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}
