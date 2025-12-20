// supabase/functions/send_welcome_email/index.ts
// Sends a welcome email to new users using Resend
// CORS headers per Dreamflow guidelines
const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

interface Payload {
  email: string;
  firstName?: string;
}

function json(body: unknown, init: ResponseInit = {}) {
  return new Response(JSON.stringify(body), {
    headers: { "content-type": "application/json", ...CORS_HEADERS, ...(init.headers || {}) },
    status: init.status ?? 200,
  });
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }
  try {
    const { email, firstName } = (await req.json()) as Payload;
    if (!email) return json({ error: 'Missing email' }, { status: 400 });

    const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');
    if (!RESEND_API_KEY) return json({ error: 'Missing RESEND_API_KEY' }, { status: 500 });

    const subject = 'Bienvenue chez KOOGWE';
    const name = firstName?.trim() || '👋';
    const html = `
      <div style="font-family: Inter, system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif; padding:24px">
        <h2>Bienvenue, ${name}!</h2>
        <p>Merci d'avoir rejoint KOOGWE. Votre compte est prêt 🚀.</p>
        <p>Vous pouvez maintenant réserver vos courses et profiter de nos services premium.</p>
        <p style="margin-top:24px;color:#666">— L'équipe KOOGWE</p>
      </div>
    `;

    const resp = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'KOOGWE <no-reply@koogwe.app>',
        to: [email],
        subject,
        html,
      }),
    });

    if (!resp.ok) {
      const err = await resp.text();
      return json({ error: 'Email send failed', details: err }, { status: 500 });
    }

    const data = await resp.json();
    return json({ ok: true, id: data.id });
  } catch (e) {
    return json({ error: 'Unexpected error', details: String(e) }, { status: 500 });
  }
});
