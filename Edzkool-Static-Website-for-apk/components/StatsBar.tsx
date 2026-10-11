import React from "react";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { Users, UserCheck, ShieldCheck, Building2 } from "lucide-react";

export default function StatsBar() {
  const stats = [
    {
      val: "1000+",
      label: "Students Mentored",
      desc: "Empowering students globally",
      icon: Users,
      accentColor: "text-purple-600",
      bgColor: "bg-purple-50",
    },
    {
      val: "15+",
      label: "Expert Mentors",
      desc: "Qualified doctor educators",
      icon: UserCheck,
      accentColor: "text-emerald-600",
      bgColor: "bg-emerald-50",
    },
    {
      val: "100%",
      label: "Visa Success Rate",
      desc: "Hassle-free documentation",
      icon: ShieldCheck,
      accentColor: "text-[#103C82]",
      bgColor: "bg-blue-50",
    },
    {
      val: "40+",
      label: "Partner Universities",
      desc: "Across Russia, Georgia & more",
      icon: Building2,
      accentColor: "text-[#F58220]",
      bgColor: "bg-orange-50",
    },
  ];

  return (
    <section className="bg-slate-50/60 py-12 border-b border-gray-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
          {stats.map((st, idx) => {
            const Icon = st.icon;
            return (
              <div
                key={idx}
                className="bg-white p-6 rounded-2xl border border-gray-100/80 shadow-xs flex flex-col items-center text-center hover:shadow-md transition-all duration-300"
              >
                <div className={`w-12 h-12 rounded-full ${st.bgColor} flex items-center justify-center mb-3`}>
                  <Icon className={`w-6 h-6 ${st.accentColor}`} />
                </div>
                <span className="text-3xl sm:text-4xl font-extrabold text-[#0B254E] tracking-tight">
                  {st.val}
                </span>
                <span className="text-sm font-bold text-gray-800 mt-1">{st.label}</span>
                <span className="text-xs text-gray-500 font-medium mt-0.5">{st.desc}</span>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
