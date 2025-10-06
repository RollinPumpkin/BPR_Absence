require('dotenv').config();
const admin = require('firebase-admin');

if (!admin.apps.length) {
  const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function seedLetterTemplates() {
  try {
    console.log('🌱 Seeding letter templates...');

    const templates = [
      {
        name: 'Warning Letter - First Warning',
        letter_type: 'warning',
        subject_template: 'First Warning - {{employee_name}}',
        content_template: `Dear {{employee_name}},

This letter serves as a formal warning regarding your {{issue_description}}. 

Details:
- Date of Incident: {{incident_date}}
- Policy Violated: {{policy_violated}}
- Description: {{incident_description}}

This is your first official warning. Please be advised that any further violations may result in more severe disciplinary action, including possible termination.

We expect immediate improvement in your performance/conduct. Please schedule a meeting with HR within 3 business days to discuss this matter.

Regards,
{{sender_name}}
{{sender_position}}`,
        variables: ['employee_name', 'issue_description', 'incident_date', 'policy_violated', 'incident_description', 'sender_name', 'sender_position'],
        category: 'disciplinary',
        requires_response: true,
        default_priority: 'high',
        created_at: admin.firestore.FieldValue.serverTimestamp()
      },
      {
        name: 'Promotion Letter',
        letter_type: 'promotion',
        subject_template: 'Congratulations on Your Promotion - {{employee_name}}',
        content_template: `Dear {{employee_name}},

We are pleased to inform you that you have been promoted to the position of {{new_position}} in the {{department}} department, effective {{effective_date}}.

New Position Details:
- Position: {{new_position}}
- Department: {{department}}
- New Salary: {{new_salary}}
- Reporting To: {{new_supervisor}}

This promotion is a recognition of your hard work, dedication, and outstanding performance. We are confident that you will excel in your new role and continue to contribute to our organization's success.

Please report to HR to complete the necessary paperwork and discuss your new responsibilities.

Congratulations once again!

Best regards,
{{sender_name}}
{{sender_position}}`,
        variables: ['employee_name', 'new_position', 'department', 'effective_date', 'new_salary', 'new_supervisor', 'sender_name', 'sender_position'],
        category: 'promotion',
        requires_response: false,
        default_priority: 'normal',
        created_at: admin.firestore.FieldValue.serverTimestamp()
      },
      {
        name: 'Transfer Notification',
        letter_type: 'transfer',
        subject_template: 'Transfer Notification - {{employee_name}}',
        content_template: `Dear {{employee_name}},

This letter is to inform you of your transfer to {{new_location}} effective {{transfer_date}}.

Transfer Details:
- New Location: {{new_location}}
- New Department: {{new_department}}
- Transfer Date: {{transfer_date}}
- Reason: {{transfer_reason}}

Please coordinate with your current supervisor to ensure a smooth transition of your responsibilities. You are required to report to {{new_supervisor}} at {{new_location}} on {{transfer_date}}.

If you have any questions or concerns regarding this transfer, please contact HR immediately.

Best regards,
{{sender_name}}
{{sender_position}}`,
        variables: ['employee_name', 'new_location', 'transfer_date', 'new_department', 'transfer_reason', 'new_supervisor', 'sender_name', 'sender_position'],
        category: 'administrative',
        requires_response: true,
        default_priority: 'high',
        created_at: admin.firestore.FieldValue.serverTimestamp()
      },
      {
        name: 'Appreciation Letter',
        letter_type: 'appreciation',
        subject_template: 'Letter of Appreciation - {{employee_name}}',
        content_template: `Dear {{employee_name}},

On behalf of the management team, I would like to express our sincere appreciation for your {{achievement_description}}.

Your dedication and hard work have not gone unnoticed. Specifically:
- {{achievement_details}}
- Impact: {{impact_description}}
- Recognition Period: {{period}}

Employees like you make our organization stronger and more successful. Your commitment to excellence is truly inspiring to your colleagues and serves as an example for others to follow.

As a token of our appreciation, {{reward_details}}.

Thank you for your continued dedication and contribution to our organization.

With gratitude,
{{sender_name}}
{{sender_position}}`,
        variables: ['employee_name', 'achievement_description', 'achievement_details', 'impact_description', 'period', 'reward_details', 'sender_name', 'sender_position'],
        category: 'recognition',
        requires_response: false,
        default_priority: 'normal',
        created_at: admin.firestore.FieldValue.serverTimestamp()
      },
      {
        name: 'General Memo',
        letter_type: 'memo',
        subject_template: 'Memorandum - {{memo_subject}}',
        content_template: `MEMORANDUM

TO: {{recipient_name}}
FROM: {{sender_name}}
DATE: {{memo_date}}
SUBJECT: {{memo_subject}}

{{memo_content}}

{{additional_instructions}}

Please acknowledge receipt of this memorandum and comply with the instructions provided.

{{sender_name}}
{{sender_position}}`,
        variables: ['recipient_name', 'sender_name', 'memo_date', 'memo_subject', 'memo_content', 'additional_instructions', 'sender_position'],
        category: 'communication',
        requires_response: true,
        default_priority: 'normal',
        created_at: admin.firestore.FieldValue.serverTimestamp()
      },
      {
        name: 'Company Announcement',
        letter_type: 'announcement',
        subject_template: 'Important Announcement - {{announcement_title}}',
        content_template: `Dear Team,

We would like to announce {{announcement_title}}.

{{announcement_content}}

Key Points:
- {{key_point_1}}
- {{key_point_2}}
- {{key_point_3}}

Effective Date: {{effective_date}}

For questions or clarifications, please contact {{contact_person}} at {{contact_email}}.

Thank you for your attention.

Best regards,
{{sender_name}}
{{sender_position}}`,
        variables: ['announcement_title', 'announcement_content', 'key_point_1', 'key_point_2', 'key_point_3', 'effective_date', 'contact_person', 'contact_email', 'sender_name', 'sender_position'],
        category: 'announcement',
        requires_response: false,
        default_priority: 'normal',
        created_at: admin.firestore.FieldValue.serverTimestamp()
      }
    ];

    for (const template of templates) {
      await db.collection('letter_templates').add(template);
      console.log(`✅ Created template: ${template.name}`);
    }

    console.log(`🎉 Successfully created ${templates.length} letter templates!`);

  } catch (error) {
    console.error('❌ Error seeding letter templates:', error);
  }
}

seedLetterTemplates();