"use client";

import { FormEvent, useState } from "react";

type FieldErrors = {
  name?: string;
  email?: string;
  message?: string;
};

function isValidEmail(value: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

export function ContactForm() {
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [errors, setErrors] = useState<FieldErrors>({});
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");

  function validate(): FieldErrors {
    const next: FieldErrors = {};
    if (!name.trim()) next.name = "Name is required.";
    if (!email.trim()) next.email = "Email is required.";
    else if (!isValidEmail(email.trim())) next.email = "Enter a valid email.";
    if (!message.trim()) next.message = "Message is required.";
    else if (message.trim().length < 10) {
      next.message = "Please write at least 10 characters.";
    }
    return next;
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitError(null);
    const nextErrors = validate();
    setErrors(nextErrors);
    if (Object.keys(nextErrors).length > 0) return;

    setLoading(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 700));
      // Mock failure path for UX: email contains "fail@"
      if (email.toLowerCase().includes("fail@")) {
        throw new Error("Could not send message. Please try again.");
      }
      setSubmitted(true);
    } catch (error) {
      setSubmitError(
        error instanceof Error ? error.message : "Something went wrong.",
      );
    } finally {
      setLoading(false);
    }
  }

  if (submitted) {
    return (
      <div
        className="border border-primary/30 bg-surface px-6 py-10"
        role="status"
      >
        <h2 className="font-display text-2xl font-semibold text-primary-dark">
          Message received
        </h2>
        <p className="mt-3 text-muted">
          Thanks{name ? `, ${name}` : ""}. This is a mock success state — no
          backend email is sent yet.
        </p>
        <button
          type="button"
          className="mt-6 text-sm font-semibold text-primary underline-offset-2 hover:underline"
          onClick={() => {
            setSubmitted(false);
            setName("");
            setEmail("");
            setMessage("");
            setErrors({});
            setSubmitError(null);
          }}
        >
          Send another message
        </button>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-5" noValidate>
      {submitError ? (
        <div
          className="rounded-xl border border-red-300 bg-red-50 px-4 py-3 text-sm text-red-800"
          role="alert"
        >
          {submitError}
        </div>
      ) : null}

      <div>
        <label htmlFor="name" className="block text-sm font-medium text-foreground">
          Name
        </label>
        <input
          id="name"
          name="name"
          autoComplete="name"
          disabled={loading}
          aria-invalid={Boolean(errors.name)}
          aria-describedby={errors.name ? "name-error" : undefined}
          value={name}
          onChange={(event) => setName(event.target.value)}
          className="mt-2 w-full rounded-xl border border-border bg-surface px-4 py-3 text-foreground outline-none transition focus:border-primary disabled:opacity-60"
        />
        {errors.name ? (
          <p id="name-error" className="mt-1 text-sm text-red-700">
            {errors.name}
          </p>
        ) : null}
      </div>

      <div>
        <label htmlFor="email" className="block text-sm font-medium text-foreground">
          Email
        </label>
        <input
          id="email"
          name="email"
          type="email"
          autoComplete="email"
          disabled={loading}
          aria-invalid={Boolean(errors.email)}
          aria-describedby={errors.email ? "email-error" : undefined}
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          className="mt-2 w-full rounded-xl border border-border bg-surface px-4 py-3 text-foreground outline-none transition focus:border-primary disabled:opacity-60"
        />
        {errors.email ? (
          <p id="email-error" className="mt-1 text-sm text-red-700">
            {errors.email}
          </p>
        ) : null}
        <p className="mt-1 text-xs text-muted">
          Tip: use an email like fail@example.com to preview the error state.
        </p>
      </div>

      <div>
        <label htmlFor="message" className="block text-sm font-medium text-foreground">
          Message
        </label>
        <textarea
          id="message"
          name="message"
          rows={5}
          disabled={loading}
          aria-invalid={Boolean(errors.message)}
          aria-describedby={errors.message ? "message-error" : undefined}
          value={message}
          onChange={(event) => setMessage(event.target.value)}
          className="mt-2 w-full rounded-xl border border-border bg-surface px-4 py-3 text-foreground outline-none transition focus:border-primary disabled:opacity-60"
        />
        {errors.message ? (
          <p id="message-error" className="mt-1 text-sm text-red-700">
            {errors.message}
          </p>
        ) : null}
      </div>

      <button
        type="submit"
        disabled={loading}
        className="inline-flex min-w-40 items-center justify-center rounded-xl bg-primary px-6 py-3.5 text-base font-semibold text-white transition hover:bg-primary-dark disabled:cursor-not-allowed disabled:opacity-70"
      >
        {loading ? "Sending…" : "Submit"}
      </button>
    </form>
  );
}
