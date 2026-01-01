// supabase/functions/send_welcome_email/index.ts
// Sends a welcome email to new users using Resend
// CORS headers for KOOGWE
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
    console.log('[send_welcome_email] Received request:', { email, firstName });
    
    if (!email) {
      console.error('[send_welcome_email] Missing email in request');
      return json({ error: 'Missing email' }, { status: 400 });
    }

    const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');
    if (!RESEND_API_KEY) {
      console.error('[send_welcome_email] RESEND_API_KEY not configured');
      return json({ 
        error: 'Missing RESEND_API_KEY', 
        hint: 'Configure RESEND_API_KEY in Supabase Dashboard → Edge Functions → Environment Variables' 
      }, { status: 500 });
    }
    
    console.log('[send_welcome_email] RESEND_API_KEY found, proceeding...');

    const subject = 'Bienvenue chez KOOGWE';
    const name = firstName?.trim() || '👋';
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="font-family: Inter, system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif; padding:24px; background-color:#f5f5f5;">
        <div style="max-width:600px; margin:0 auto; background-color:white; padding:32px; border-radius:8px; box-shadow:0 2px 4px rgba(0,0,0,0.1);">
          <h2 style="color:#333; margin-top:0;">Bienvenue, ${name}!</h2>
          <p style="color:#666; line-height:1.6;">Merci d'avoir rejoint KOOGWE. Votre compte est prêt 🚀.</p>
          <p style="color:#666; line-height:1.6;">Vous pouvez maintenant réserver vos courses et profiter de nos services premium.</p>
          <p style="margin-top:24px;color:#666; font-size:14px;">— L'équipe KOOGWE</p>
        </div>
      </body>
      </html>
    `;

    // Utiliser le domaine de test Resend par défaut (fonctionne sans vérification)
    // Pour utiliser votre propre domaine, vérifiez-le dans Resend et changez cette valeur
    const fromEmail = Deno.env.get('RESEND_FROM_EMAIL') || 'KOOGWE <onboarding@resend.dev>';
    console.log('[send_welcome_email] Using from email:', fromEmail);
    
    const emailPayload = {
      from: fromEmail,
      to: [email],
      subject,
      html,
    };
    console.log('[send_welcome_email] Sending email to Resend API...');
    
    const resp = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(emailPayload),
    });

    if (!resp.ok) {
      const err = await resp.text();
      console.error('[send_welcome_email] Resend API error:', resp.status, err);
      return json({ 
        error: 'Email send failed', 
        details: err,
        statusCode: resp.status 
      }, { status: 500 });
    }

    const data = await resp.json();
    console.log('[send_welcome_email] Email sent successfully:', data.id);
    return json({ ok: true, id: data.id, message: 'Email sent successfully' });
  } catch (e) {
    console.error('[send_welcome_email] Unexpected error:', e);
    return json({ 
      error: 'Unexpected error', 
      details: String(e),
      stack: e instanceof Error ? e.stack : undefined
    }, { status: 500 });
  }
});
