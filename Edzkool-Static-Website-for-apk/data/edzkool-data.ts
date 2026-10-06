import React from "react";

export interface Program {
  id: string;
  name: string;
  slug: string;
  description: string;
  duration: string;
  mode: string;
  features: string[];
  image: string;
}

export interface Testimonial {
  name: string;
  exam: string;
  score: string;
  review: string;
  image: string;
}

export interface ServiceItem {
  title: string;
  description: string;
  icon: string;
}

export interface Faq {
  question: string;
  answer: string;
  category: string;
}

export const EDZKOOL_DATA = {
  company: {
    name: "Edzkool",
    tagline: "Empowering Minds Through Personalized Learning",
    heroSubtitle:
      "Premium online 1-to-1 tuition, specialized coaching classes, IELTS, English, and Coding for students worldwide.",
    establishedYear: 2020,
    studentsMentored: "5000+",
    successRate: "98%",
    partnerUniversities: "50+",
    email: "care@edzkool.com",
    phone: "+91 98765 43210",
    headOffice: "2316, 16th Cross Rd, HSR Layout, Bengaluru",
    globalPresence: ["Online Worldwide", "India", "UAE", "UK", "Canada"],
  },
  programs: [
    {
      id: "ielts",
      name: "IELTS Preparation",
      slug: "ielts",
      description:
        "Comprehensive IELTS coaching with personalized feedback, mock tests, and speaking practice sessions to guarantee high band scores.",
      duration: "3-6 Months",
      mode: "1-on-1 Online",
      features: [
        "Native-level English trainers",
        "Weekly mock tests and performance tracking",
        "Intensive speaking and writing feedback",
        "Flexible scheduling"
      ],
      image: "/Hisham/abroad.png"
    },
    {
      id: "grades-1-10",
      name: "Tuition Grades 1-10",
      slug: "grades-1-10",
      description:
        "Interactive online tuition for primary and secondary school students. Covering Math, Science, and English with dedicated tutors.",
      duration: "Academic Year",
      mode: "1-on-1 Online",
      features: [
        "Curriculum mapped to school boards (CBSE, ICSE, IGCSE)",
        "Interactive whiteboard sessions",
        "Regular parent-teacher updates",
        "Doubt clearing on demand"
      ],
      image: "/Hisham/14.png"
    },
    {
      id: "coding",
      name: "Coding Classes",
      slug: "coding",
      description:
        "Learn Python, Web Development, and Scratch programming. Designed specifically for kids and teens to build a strong logical foundation.",
      duration: "3-12 Months",
      mode: "1-on-1 Online",
      features: [
        "Project-based learning approach",
        "Build real-world apps and games",
        "Logic and algorithmic thinking",
        "Live code review"
      ],
      image: "/Hisham/16.png"
    },
    {
      id: "english",
      name: "Spoken English",
      slug: "english",
      description:
        "Improve your fluency, vocabulary, and confidence with our dedicated spoken English classes tailored to your proficiency level.",
      duration: "2-6 Months",
      mode: "1-on-1 Online",
      features: [
        "Conversational practice",
        "Accent neutralization",
        "Grammar and vocabulary building",
        "Real-life scenarios roleplay"
      ],
      image: "/Hisham/20.png"
    }
  ] as Program[],
  services: [
    {
      title: "1-on-1 Mentorship",
      description: "Dedicated tutors providing focused, undivided attention to maximize your learning potential.",
      icon: "User",
    },
    {
      title: "Flexible Timings",
      description: "Schedule classes according to your convenience and time zone.",
      icon: "Clock",
    },
    {
      title: "Interactive Platform",
      description: "State-of-the-art virtual classrooms with digital whiteboards and shared workspaces.",
      icon: "Monitor",
    },
    {
      title: "Progress Tracking",
      description: "Weekly assessments and detailed analytical reports shared with parents.",
      icon: "TrendingUp",
    }
  ],
  testimonials: [
    {
      name: "Aarav Sharma",
      exam: "IELTS Academic",
      score: "Band 8.0",
      review: "The 1-on-1 IELTS coaching was incredible. My tutor identified my weaknesses in writing and helped me improve dramatically.",
      image: "/Hisham/ashik.webp",
    },
    {
      name: "Riya Gupta",
      exam: "Grade 9 Math",
      score: "95%",
      review: "Math used to be my weakest subject. Edzkool's personalized tutoring helped me understand the concepts rather than just memorizing formulas.",
      image: "/Hisham/ashik.webp",
    },
    {
      name: "Aryan Patel",
      exam: "Python Coding",
      score: "Advanced",
      review: "I built my first web app after just 3 months of coding classes. The live code reviews make a huge difference.",
      image: "/Hisham/ashik.webp",
    },
  ] as Testimonial[],
  faqs: [
    {
      question: "Are the classes group sessions or 1-on-1?",
      answer: "All our premium coaching classes are strictly 1-on-1 to ensure personalized attention and optimal learning outcomes.",
      category: "General",
    },
    {
      question: "Do you offer a free trial class?",
      answer: "Yes! We offer a free 30-minute demonstration class so you can experience our interactive platform and teaching methodology.",
      category: "Admissions",
    },
    {
      question: "Which curriculums do you support for Grades 1-10?",
      answer: "We have specialized tutors for CBSE, ICSE, state boards, and international boards like IGCSE and IB.",
      category: "Academics",
    },
    {
      question: "How are the coding classes structured for kids?",
      answer: "We use a highly visual, project-based curriculum starting from block-based programming (Scratch) and gradually moving to text-based languages like Python.",
      category: "Academics",
    },
  ] as Faq[],
  leadership: {
    subtitle: "OUR LEADERSHIP",
    quote: "Education is not just about passing exams, it's about igniting a lifelong passion for learning. Our goal is to empower every student to reach their highest potential.",
    author: "Dr. A. Rahman",
    role: "Founder & Academic Director",
    body: "We believe in the power of personalized mentorship.",
    image: "/Hisham/ashik.webp",
  },
};
