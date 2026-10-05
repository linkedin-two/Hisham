import re

with open("data/edzkool-data.ts", "r") as f:
    content = f.read()

leadership_data = """  leadership: {
    subtitle: "OUR LEADERSHIP",
    quote: "Education is not just about passing exams, it's about igniting a lifelong passion for learning. Our goal is to empower every student to reach their highest potential.",
    name: "Dr. A. Rahman",
    designation: "Founder & Academic Director",
    image: "/ashik.webp",
  },
};"""

content = content.replace("  ] as Faq[],\n};", "  ] as Faq[],\n" + leadership_data)

with open("data/edzkool-data.ts", "w") as f:
    f.write(content)
