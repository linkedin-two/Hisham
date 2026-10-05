export interface BlogPost {
  slug: string;
  title: string;
  excerpt: string;
  date: string;
  author: string;
  content: string;
  category: string;
}

export const BLOG_POSTS: BlogPost[] = [
  {
    slug: "benefits-of-1-on-1-coaching",
    title: "Why 1-on-1 Coaching is Better Than Traditional Classes",
    excerpt: "Discover how personalized attention can dramatically improve your child's grades and confidence.",
    date: "2026-09-15",
    author: "Dr. Ananya Sharma",
    category: "Academics",
    content: "Traditional classrooms often leave students behind. In a 1-on-1 setting, tutors can identify specific weaknesses and tailor the curriculum to the student's learning speed. At Edzkool, we ensure every student gets the undivided attention they deserve.",
  },
  {
    slug: "how-to-score-band-8-ielts",
    title: "How to Score Band 8.0+ in IELTS",
    excerpt: "A comprehensive guide on cracking the IELTS speaking and writing modules.",
    date: "2026-09-28",
    author: "Rahul Verma",
    category: "IELTS",
    content: "Scoring a high band in IELTS requires more than just good English; it requires strategy. Our native-level trainers at Edzkool focus on time management, vocabulary building, and intensive mock speaking tests to guarantee success.",
  },
  {
    slug: "why-kids-should-learn-coding",
    title: "Why Kids Should Learn Coding in 2026",
    excerpt: "Programming isn't just for software engineers anymore. It's a critical life skill.",
    date: "2026-10-01",
    author: "Sanjay Gupta",
    category: "Coding",
    content: "Learning to code teaches children logical thinking, problem-solving, and creativity. With our interactive coding curriculum (Scratch and Python), kids can build their own games and apps while having fun learning.",
  }
];
