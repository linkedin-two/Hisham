import React from "react";
import { EDZKOOL_DATA } from "@/data/edzkool-data";
import { Users, Globe2, ShieldCheck, HeartHandshake } from "lucide-react";

export default function StatsBar() {
  const stats = [
    {
      label: "Students Placed",
      val: EDZKOOL_DATA.company.studentsMentored,
      desc: "Empowering students globally",
      icon: Users,
      accentColor: "text-bright-purple",
      bgColor: "bg-purple-100",
    },
    {
      label: "Global Presence",
      val: EDZKOOL_DATA.company.globalPresence.length.toString(),
      desc: "Students across the globe",
      icon: Globe2,
      accentColor: "text-bright-teal",
      bgColor: "bg-emerald-100",
    },
    {
      label: "NMC Compliance",
      val: "100%",
      desc: "English medium NMC & WHO recognized universities",
      icon: ShieldCheck,
      accentColor: "text-blue-600",
      bgColor: "bg-blue-100",
    },
    {
      label: "Donation Fee",
      val: "₹0",
      desc: "Transparent university fee paid directly to uni",
      icon: HeartHandshake,
      accentColor: "text-bright-red",
      bgColor: "bg-rose-100",
    },
  ];

  return (
    <section className="bg-white py-12 border-y border-gray-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-6 md:gap-8">
          {stats.map((st, idx) => {
            const Icon = st.icon;
            return (
              <div
                key={idx}
                className="bg-bright-bg/50 p-6 rounded-2xl border border-gray-100 flex flex-col items-center text-center hover:bg-white hover:shadow-card-soft transition-all duration-300"
              >
                <div className={`w-12 h-12 rounded-full ${st.bgColor} flex items-center justify-center mb-3`}>
                  <Icon className={`w-6 h-6 ${st.accentColor}`} />
                </div>
                <span className="text-3xl sm:text-4xl font-black text-gray-900 tracking-tight">
                  {st.val}
                </span>
                <span className="text-sm font-extrabold text-gray-800 mt-1">{st.label}</span>
                <span className="text-xs text-gray-500 font-medium mt-1">{st.desc}</span>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
