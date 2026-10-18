import React from "react";

export default function HowItWorks() {
  const steps = [
    {
      n: "01",
      title: "Book a free demo",
      text: "Share your child’s grade and interests in the short form.",
    },
    {
      n: "02",
      title: "Meet the teacher",
      text: "Join a live demo class and see how lessons feel.",
    },
    {
      n: "03",
      title: "Talk to an advisor",
      text: "We suggest a learning path and answer every question.",
    },
    {
      n: "04",
      title: "Start learning",
      text: "Pick your program, set a schedule and begin.",
    },
  ];

  return (
    <section className="bg-[#F4F8FE]">
      <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-12">
        <div className="flex flex-col gap-3.5 max-w-[680px]">
          <div className="text-[#A85B00] font-bold text-sm tracking-widest uppercase">
            How it works
          </div>
          <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
            From first hello to first class in four steps.
          </h2>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {steps.map((st) => (
            <div
              key={st.n}
              className="bg-white rounded-[22px] p-7 md:p-8 flex flex-col gap-3.5 border border-[#E3EAF4] shadow-xs"
            >
              <div className="font-serif text-4xl sm:text-[44px] font-bold text-[#FD9202] leading-none">
                {st.n}
              </div>
              <h3 className="text-xl sm:text-[22px] font-bold text-[#0B2A5B]">
                {st.title}
              </h3>
              <p className="text-[15px] leading-relaxed text-[#44546F]">
                {st.text}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
