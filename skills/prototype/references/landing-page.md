# Landing page

Read this when the product spec declares a landing page or marketing site,
at intake (to structure the study), in research (to look at what competitors'
pages do), and in phase 7 by the designer building that flow. pen.dev's own
`guide/landing-page.md` (via `read_skill`) covers the mechanics of building
one on the canvas; this file covers what the page has to do.

A landing page has one job: move a specific visitor to one action. Everything
on it either helps that or is in the way. Most generated landing pages fail
before any pixel is drawn, because nobody decided who the visitor is, what
they already believe, and what the one action is. The study below is that
decision, and it lives in the product spec under **Landing page**.

## The study (written at intake)

1. **The visitor.** Which persona lands here, from where (an ad, a search, a
   recommendation, an app store link), and what they already know when they
   arrive. A visitor from a comparison article needs different proof than one
   who clicked a friend's link.
2. **The one action.** Sign up, join a waitlist, download, book a demo, buy.
   One. If the business needs two (buy or talk to sales), one is primary and
   the other is a text link, never two equal buttons.
3. **The objection list.** The three to five reasons this visitor would not
   act, in the order they occur to them. Price, trust, effort to switch, "does
   it work for my case", "is this real". Each section below exists to answer
   one of these, and a section that answers none of them is cut.
4. **Proof available.** What the product can honestly show: real screens (the
   prototype's own), numbers, names, logos, quotes. What it cannot show yet is
   not invented; the section is designed to hold it and marked as pending in
   the spec.
5. **Section order**, derived from 1 to 4. The default narrative, which
   research may adjust for the category:

   | # | Section | Answers |
   |---|---|---|
   | 1 | Hero: what it is, for whom, the action | "What is this?" in five seconds |
   | 2 | The product itself, shown, not described | "Is this real?" |
   | 3 | How it works, in three or four steps | "How much effort is this?" |
   | 4 | The outcomes, framed as the visitor's job done | "Is this for my case?" |
   | 5 | Proof: quotes, numbers, logos, a case | "Can I trust it?" |
   | 6 | Price, or how to get it | "What does it cost?" |
   | 7 | Objections left, as questions and short answers | the rest of the list |
   | 8 | The action again, with the strongest reason | close |
   | 9 | Footer: legal, contact, secondary links | orientation |

   Drop what has nothing to say. A waitlist page for a hardware product has
   no pricing section and no FAQ; a B2B tool has no "how it works" if the
   demo is the how.

6. **Secondary screens**: the form confirmation (what happens after the
   action), the error on submit, 404, and whatever legal pages the footer
   links to. These are listed in the spec's secondary screens table.

## Research inputs

When a landing page is in scope, `design/research.md` adds a short section:
what the competitors' pages lead with, what proof they show, where their
action sits, and what every one of them does identically (that last item is
the map of where not to go, as with brand territory).

## What the direction has to decide for it

The direction file already declares type, palette, density, grid and
navigation per viewport. For a landing page it also states, in the
navigation item: the top nav's items (four to seven), whether it is sticky,
and where the action sits in it. The composition intent per section follows
`layout.md` §1 (the marketing archetypes); the ban list in `anti-generic.md`
applies with particular force here, since the centered hero with two buttons
and the three identical feature cards are the two most recognizable defaults
in the medium.

## Craft specific to the page

- **The headline says what the product is.** Not the benefit in the abstract
  ("Work smarter"), the thing ("A coffee roaster for your kitchen counter").
  The subhead carries the benefit and the audience.
- **The action is the same words everywhere it appears.** One label,
  repeated, so the visitor recognizes it.
- **Show the product before explaining it.** Section 2 uses the prototype's
  real screens (instanced from the flow regions, or `Generate` for a hardware
  product), not an illustration of the concept.
- **Every section has one job and a heading that states it** in the visitor's
  words. A section the visitor cannot summarize in a sentence is two sections
  or none.
- **Proof is specific or absent.** "Trusted by 3,000 roasters" or nothing.
  Never a row of grey placeholder logos.
- **The page is content-height like every screen**, at each declared
  viewport. On mobile the sections stack and the action stays reachable near
  the top and again at the end.
- **Forms ask for the minimum.** A waitlist takes an email. A demo request
  takes an email and a company. Each extra field costs conversions and the
  spec says why it earns its place.

## Audit

The rubric's existing criteria cover the page. Two are checked with extra
care: 3.3 (the hero and feature-grid defaults) and 4.10 (the confirmation and
error states exist). The auditor also reads the spec's landing study and
checks that every section it lists is on the canvas, in the order it says,
and that the page has exactly one primary action.
