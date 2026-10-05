import React from "react";
import { EDZKOOL_DATA } from "@/data/edzkool-data";

export default function JsonLdSchema() {
  const organizationSchema = {
    "@context": "https://schema.org",
    "@type": "EducationalOrganization",
    name: EDZKOOL_DATA.company.name,
    alternateName: "Edzkool Online Coaching",
    url: "https://www.edzkool.com",
    logo: "https://edzkool.com/assets/logo1.png",
    description: EDZKOOL_DATA.company.heroSubtitle,
    telephone: EDZKOOL_DATA.company.phone,
    email: EDZKOOL_DATA.company.email,
    address: {
      "@type": "PostalAddress",
      streetAddress: "2316, 16th Cross Rd, HSR Layout",
      addressLocality: "Bengaluru",
      addressRegion: "Karnataka",
      postalCode: "560102",
      addressCountry: "IN",
    },
    sameAs: [
      "https://www.facebook.com/edzkool",
      "https://www.instagram.com/edzkool",
      "https://www.youtube.com/@edzkool",
    ],
  };

  const faqSchema = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: EDZKOOL_DATA.faqs.map((f) => ({
      "@type": "Question",
      name: f.question,
      acceptedAnswer: {
        "@type": "Answer",
        text: f.answer,
      },
    })),
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqSchema) }}
      />
    </>
  );
}
