---
comments: false
date: "2018-07-05T00:00:00Z"
image: /img/book-copy.jpg
title: 'Book review - Clean Architecture: A Craftsman''s Guide to Software Structure
  and Design'
aliases:
- /2018/07/book-review-clean-architecture
---

I think it was around 2009 when I started reading a book called [Clean Code](https://www.amazon.com/gp/product/0132350882/ref=as_li_tl?ie=UTF8&tag=jreijnblog-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=0132350882&linkId=e0fd05eaf523f61ae0fe4fb27b4a4821) by Robert C Martin (a.k.a Uncle Bob). I found the book on a so-called 'top 10 must-reads' for software engineers. I really enjoyed reading that book. It had a pleasant writing style, well structured and provided some valuable insights. A few years later "[The Clean Coder](https://www.amazon.com/gp/product/0137081073/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0137081073&linkCode=as2&tag=jreijnblog-20&linkId=363e18b4bed01edea269dbf0fce16583)" was published and what appealed to me this time was that it was a book about some of the other aspects of our trade: professionalism, handling pressure, clear communication, etc.  If you have not read it yet or are looking to improve some of your softer skills I would recommend reading it.

I was quite excited when a few weeks ago I discovered that Robert published another book titled “[Clean Architecture: A Craftsman's Guide to Software Structure and Design](https://www.amazon.com/gp/product/0134494164/ref=as_li_tl?ie=UTF8&tag=jreijnblog-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=0134494164&linkId=02cf367dada2ce397e117b47bb0f4963)”. In this third book, Robert focusses on software design and architecture. 

## The first chapters

The book is divided into six main parts:

* Introduction to design and architecture
* Programming paradigms
* Design principles
* Component principles
* Architecture
* Details

Robert starts with his own utopian definition: 

> “The goal of software architecture is to minimize the human resources required to build and maintain the required system.”

The definition resonates with me. It's a compact definition with a lot of angles.

The first three parts of the book are mostly an introduction to software design. He describes three different programming paradigms i.e. structured programming, object-oriented programming, and functional programming. The part about design principles covers most of what was already written in Clean Code namely the SOLID principles. The reiteration did not bother me that much. I’m not sure about you, but I need to reflect on these principles once in a while. It even helps that the principles are explained with some concrete examples.

The first few chapters also contain some thought-provoking questions. Robert shares his own perspective on these questions while he continuous, but while reading the book I enjoyed taking a little pause to think about these questions before I continued reading. One of the questions from the first part of the book that I really liked was:

“Function or architecture? Which of these two provides the greater value? Is it more important for the software system to work, or is it more important for the software system to be easy to change?”

I think this depends on a lot of factors, but *what do you think*?

## Clean architecture

The part about Architecture leads us to the concept of a Clean Architecture which is clearly the main advice of the book. Robert describes the Clean Architecture as an architecture that pushes us to separate stable business rules (higher-level abstractions) from volatile technical details (lower-level details), defining clear boundaries. The main building block is the dependency rule: source code dependencies must point only inward, toward higher-level policies.

A clean architecture should have the following characteristics:

* Testable
* Independent of frameworks
* Independent of the UI
* Independent of the database
* Independent of any external agency

The last chapter in the architecture part is about clean embedded architecture and is written by a guest author James Grenning. I really liked this chapter as it gives some practical insights into the complexity of embedded software and the use of abstraction layers between hardware, firmware, operating systems and the actual software.

Throughout the book, Robert sometimes calls certain choices an architectural detail. He mentions things like a database, GUI or framework. He says that those details don't matter much when it comes to software architecture and that you should postpone the choice for a particular database or framework as much as possible. Even though this makes sense, in theory, it contradicts what I've seen in practice. Most of the time a project starts, high-level concepts are designed and an engineering team selects a framework and database when they begin the project. What I think is important though that you make sure you decouple as much as possible from your framework and database choices, so your actual business logic is not tightly coupled with either of them. This way you can always choose an alternative solution without having to change your actual business logic too much.

The last chapter of the book (The missing chapter) is a bit different. It’s also written by another guest author (Simon Brown) and carries in my perspective a different view on how to organize or structure code. Simon is putting Clean Architecture a little on the side and goes through several different ways of structuring code: package by layer, package by feature, ports and adapters, and package by component. It's nice to see some practical examples of these different structures. I've used some of them in recent projects, but it made me think about the decisions we made.

## Summary

I liked the book overall. It’s well written and offers some practical advice. I did miss a comparison with some other more modern architectures like C4, hexagonal, or the onion architecture. If you want to read up on software design and read about an opinionated architecture it’s a book to put on your reading list.