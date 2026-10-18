import React from "react";
import Link from "next/link";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

export default function AboutPage() {
  const values = [
    {
      n: "1",
      title: "Live and personal",
      text: "Real teachers, real conversations, and feedback that helps a child improve next time.",
      bg: "#F4F8FE",
      chip: "#144787",
      chipText: "#FFFFFF",
    },
    {
      n: "2",
      title: "Skills for tomorrow",
      text: "Coding and languages sit beside school subjects, so curiosity grows along with marks.",
      bg: "#FFF8EC",
      chip: "#FD9202",
      chipText: "#0B2A5B",
    },
    {
      n: "3",
      title: "Calm, not stressful",
      text: "We value progress over pressure, so children enjoy learning and keep at it.",
      bg: "#F4F8FE",
      chip: "#144787",
      chipText: "#FFFFFF",
    },
    {
      n: "4",
      title: "Parents in the loop",
      text: "Clear updates on progress and a team you can talk to whenever you have questions.",
      bg: "#FFF8EC",
      chip: "#FD9202",
      chipText: "#0B2A5B",
    },
  ];

  const teachers = [
    {
      initials: "MS",
      color: "bg-[#144787] text-white",
      name: "Meera Sen",
      role: "Head of Mathematics · M.Sc. Math · 10+ yrs exp",
      bio: "Specializes in conceptual visualization and fear-free problem solving for middle and high school learners.",
    },
    {
      initials: "AK",
      color: "bg-[#FD9202] text-[#0B2A5B]",
      name: "Arjun Kulkarni",
      role: "Lead Tech & Robotics Mentor · B.Tech CS · 7+ yrs exp",
      bio: "Passionate about empowering young coders with project-based building, game logic, and app design.",
    },
    {
      initials: "SL",
      color: "bg-[#0B2A5B] text-white",
      name: "Sarah Lawrence",
      role: "Language & Communication Coach · MA English, CELTA · 8+ yrs exp",
      bio: "Focuses on interactive conversation mastery, public speaking, and joyful reading habits.",
    },
    {
      initials: "RP",
      color: "bg-[#144787] text-white",
      name: "Dr. Rajesh Pandey",
      role: "Senior Science Educator · Ph.D. Physics · 12+ yrs exp",
      bio: "Brings science to life through everyday live experiments and interactive digital whiteboard demos.",
    },
  ];

  return (
    <main className="min-h-screen bg-white">
      <Navbar />

      {/* Hero */}
      <section className="bg-gradient-to-b from-[#F4F8FE] to-white">
        <div className="max-w-[1200px] mx-auto px-6 py-16 md:py-20 flex flex-wrap gap-12 items-center">
          <div className="flex-1 min-w-[280px] md:min-w-[420px] flex flex-col gap-6">
            <div className="inline-flex self-start bg-[#FFF1DB] text-[#8A4B00] text-[13px] font-bold tracking-wider uppercase px-3.5 py-2 rounded-full">
              About EDZKOOL
            </div>
            <h1 className="font-serif text-4xl sm:text-5xl lg:text-[56px] leading-[1.08] font-bold text-[#0B2A5B] tracking-tight">
              A school built around curious children.
            </h1>
            <p className="text-lg sm:text-[19px] leading-relaxed text-[#44546F] max-w-[560px]">
              EDZKOOL is an online school and tuition centre for Grades 1 to 12, with coding and language courses that grow skills beyond the syllabus.
            </p>
          </div>
          <div className="flex-1 min-w-[280px] md:min-w-[400px] flex justify-center">
            <img
              src="/edzkool_new_images/about-top-section.png"
              alt="A school built around curious children"
              className="w-full max-w-[540px] h-auto object-contain block rounded-3xl shadow-sm"
            />
          </div>
        </div>
      </section>

      {/* Mission */}
      <section className="bg-[#144787] text-white">
        <div className="max-w-[900px] mx-auto px-6 py-20 flex flex-col gap-5 text-center items-center">
          <div className="text-[#FFB84D] font-bold text-sm tracking-widest uppercase">
            Our belief
          </div>
          <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight font-bold">
            Every child deserves a teacher who truly sees them, not just their scores.
          </h2>
          <p className="text-base sm:text-lg leading-relaxed text-[#D6E3F6] max-w-[680px]">
            We keep learning live, personal and joyful, so children leave each class a little more capable and a lot more confident.
          </p>
        </div>
      </section>

      {/* Values / Promises */}
      <section className="bg-white">
        <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-12">
          <div className="flex flex-col gap-3.5 max-w-[680px]">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              What we stand for
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
              Four promises to every family.
            </h2>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {values.map((v) => (
              <div
                key={v.n}
                style={{ backgroundColor: v.bg }}
                className="rounded-3xl p-8 flex flex-col gap-4 border border-[#E3EAF4] shadow-xs"
              >
                <div
                  style={{ backgroundColor: v.chip, color: v.chipText }}
                  className="w-12 h-12 rounded-2xl font-serif font-bold text-2xl flex items-center justify-center shrink-0"
                >
                  {v.n}
                </div>
                <h3 className="font-serif text-2xl font-bold text-[#0B2A5B]">
                  {v.title}
                </h3>
                <p className="text-base leading-relaxed text-[#44546F]">
                  {v.text}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Story Note */}
      <section className="bg-[#FFF8EC]">
        <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-wrap gap-12 items-center">
          <div className="flex-1 min-w-[280px] md:min-w-[340px] flex justify-center">
            <div className="w-full max-w-[340px] aspect-square rounded-[32px] bg-[#144787] text-white flex flex-col items-center justify-center gap-3 text-center p-6 shadow-md">
              <div className="w-20 h-20 rounded-full bg-[#FFB84D] text-[#0B2A5B] flex items-center justify-center font-serif text-3xl font-bold">
                EZ
              </div>
              <div className="font-serif text-2xl font-bold text-[#FFB84D]">
                EDZKOOL
              </div>
              <div className="text-sm text-[#D6E3F6]">
                Founded with a mission to make education personal & inspiring
              </div>
            </div>
          </div>
          <div className="flex-1 min-w-[280px] md:min-w-[440px] flex flex-col gap-4">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              Our story
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl text-[#0B2A5B] font-bold leading-snug">
              Learning should spark curiosity, not stress.
            </h2>
            <p className="text-[17px] leading-relaxed text-[#44546F]">
              EDZKOOL began with a straightforward observation: in crowded tuition batches and rigid lecture halls, children often stay quiet rather than ask their real doubts.
            </p>
            <p className="text-[17px] leading-relaxed text-[#44546F]">
              By bringing together dedicated 1-on-1 educators, interactive digital classrooms, and balanced skill curriculums, we created a place where students are heard, supported, and guided at their own pace.
            </p>
          </div>
        </div>
      </section>

      {/* Educators */}
      <section className="bg-white">
        <div className="max-w-[1200px] mx-auto px-6 py-20 md:py-24 flex flex-col gap-12">
          <div className="flex flex-col gap-3.5 max-w-[680px]">
            <div className="text-[#A85B00] font-bold text-sm tracking-wider uppercase">
              Our educators
            </div>
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight text-[#0B2A5B] tracking-tight">
              Meet the people behind the screen.
            </h2>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {teachers.map((t, idx) => (
              <div
                key={idx}
                className="border border-[#E3EAF4] rounded-3xl p-7 flex flex-col gap-3.5 shadow-xs hover:border-[#144787] transition-all"
              >
                <div
                  className={`w-16 h-16 rounded-full font-serif text-2xl font-bold flex items-center justify-center shrink-0 ${t.color}`}
                >
                  {t.initials}
                </div>
                <h3 className="font-serif text-2xl font-bold text-[#0B2A5B]">
                  {t.name}
                </h3>
                <div className="text-xs font-bold text-[#144787]">
                  {t.role}
                </div>
                <p className="text-[14px] text-[#44546F] leading-relaxed flex-1">
                  {t.bio}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pre-Footer CTA */}
      <section className="bg-[#144787] text-white">
        <div className="max-w-[1200px] mx-auto px-6 py-16 md:py-20 flex flex-wrap gap-7 items-center justify-between">
          <div className="flex-1 min-w-[300px] md:min-w-[440px] flex flex-col gap-3">
            <h2 className="font-serif text-3xl sm:text-4xl lg:text-[44px] leading-tight font-bold">
              Come and meet us in a live class.
            </h2>
            <p className="text-base sm:text-[17px] text-[#D6E3F6] leading-relaxed">
              Book a free demo and see how EDZKOOL feels for your child.
            </p>
          </div>
          <Link
            href="/contact"
            className="bg-[#FD9202] hover:bg-[#e88500] text-[#0B2A5B] font-bold text-base md:text-[17px] px-8 py-4 rounded-full inline-block transition-transform transform hover:-translate-y-0.5 shadow-md"
          >
            Book a free demo class
          </Link>
        </div>
      </section>

      <Footer />
    </main>
  );
}
