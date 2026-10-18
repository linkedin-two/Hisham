import React from "react";

export default function Testimonials() {
  const testimonials = [
    {
      quote:
        "The 1-on-1 attention transformed my daughter's confidence in Math. Her tutor doesn't just teach the syllabus, but makes sure she actually understands every concept without feeling pressured.",
      author: "Priya Sharma",
      role: "Parent of Grade 7 student, Bengaluru",
    },
    {
      quote:
        "My son loves his coding and robotics classes. In just three months, he built two playable games of his own. EDZKOOL makes learning feel interactive, productive, and joyful.",
      author: "Mohammed Al-Mansoor",
      role: "Parent of Grade 5 student, Dubai",
    },
    {
      quote:
        "The teachers are punctual, exceptionally patient, and genuinely know our child by name. The regular weekly progress reports keep us completely in the loop.",
      author: "Anita Roy",
      role: "Parent of Grade 10 student, New Delhi",
    },
  ];

  return (
    <section className="bg-[#FFF8EC]">
      <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-12">
        <div className="flex flex-col gap-3.5 max-w-[680px]">
          <div className="text-[#A85B00] font-bold text-sm tracking-widest uppercase">
            Parent voices
          </div>
          <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
            What families say about EDZKOOL.
          </h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {testimonials.map((t, idx) => (
            <figure
              key={idx}
              className="m-0 bg-white rounded-3xl p-8 flex flex-col gap-4 border border-[#F3E3C8] shadow-xs"
            >
              <div className="font-serif text-5xl leading-[0.6] text-[#FD9202]">
                “
              </div>
              <blockquote className="m-0 text-[17px] leading-relaxed text-[#1B2A44] flex-1">
                {t.quote}
              </blockquote>
              <figcaption className="font-bold text-[#144787] text-[15px] pt-2 border-t border-gray-100">
                {t.author} <span className="text-[#44546F] font-normal block text-xs mt-0.5">{t.role}</span>
              </figcaption>
            </figure>
          ))}
        </div>
      </div>
    </section>
  );
}
