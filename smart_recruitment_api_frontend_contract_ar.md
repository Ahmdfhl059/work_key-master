# وثيقة APIs المطلوبة لفريق الفرونت — Smart Recruitment Platform

**الإصدار:** 1.0  
**التاريخ:** 2026-06-29  
**النطاق:** Backend APIs للـ MVP مع حالة التنفيذ الحالية حسب الريبو `master`  
**Base URL المقترح:** `/api/v1`  
**نوع النظام:** Laravel REST API + JSON + Sanctum Bearer Tokens

---

## 1. معنى حالة كل API

| الرمز | الحالة | المعنى العملي |
|---|---|---|
| ✅ | منجز | الـ endpoint ظاهر ضمن الريبو/تقرير التنفيذ ويغطي السيناريو الأساسي المطلوب. |
| 🟡 | منجز جزئياً | الـ endpoint موجود أو جزء كبير منه موجود، لكن ينقصه حقل/سيناريو/تفصيل مهم لفريق الفرونت أو للـ MVP الكامل. |
| ⬜ | غير منجز | غير ظاهر كـ endpoint مستقل في الريبو الحالي ويجب تنفيذه إذا أردنا تغطية الـ Use Case كاملاً. |
| ⚠️ | موجود لكن يحتاج توحيد | موجود تقنياً لكن الاسم/القيم/التدفق مختلف عن السيناريو المعتمد ويحتاج قرار توحيد قبل اعتماد الفرونت عليه. |

> ملاحظة: هذه الوثيقة تفصل الـ APIs المطلوبة كعقد Backend/Frontend. لا تعني أن كل شيء يجب تنفيذه دفعة واحدة؛ الأفضل التنفيذ حسب المراحل.

---

## 2. قواعد عامة يجب أن يعتمدها فريق الفرونت

### 2.1 Envelope موحّد للاستجابة

كل API يجب أن يرجع استجابة JSON موحدة:

```json
{
  "success": true,
  "message": "Operation completed successfully.",
  "data": {}
}
```

وعند الخطأ:

```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

### 2.2 المصادقة والصلاحيات

| الحالة | المطلوب من الفرونت |
|---|---|
| Public endpoint | لا يرسل Token. |
| Authenticated endpoint | يرسل `Authorization: Bearer <token>`. |
| Role protected endpoint | يرسل Token، والباكيند يتحقق من الدور: `job_seeker`, `employer`, `admin`. |
| Owner protected endpoint | لا يكفي الدور؛ يجب أن يكون المستخدم مالك المورد أو تابع لنفس الشركة. |

### 2.3 Pagination و Filtering

أي قائمة يجب أن تدعم على الأقل:

| Query Param | النوع | ملاحظات |
|---|---|---|
| `page` | integer | رقم الصفحة. |
| `per_page` | integer | يفضل 10/15/20، والحد الأعلى 100. |
| `search` | string | عند الحاجة للبحث النصي. |
| `status` | string | للطلبات، الوظائف، المقابلات، الاختبارات. |
| `sort_by` | string | اختياري إذا تم تنفيذه لاحقاً. |
| `sort_dir` | `asc/desc` | اختياري. |

---

## 3. Enums يجب توحيدها بين الباكيند والفرونت

### 3.1 User Roles

| القيمة | الواجهة |
|---|---|
| `job_seeker` | Job Seeker App/Web |
| `employer` | Employer Dashboard |
| `admin` | Admin Dashboard |

### 3.2 User Status

| القيمة | المعنى |
|---|---|
| `active` | يمكنه استخدام النظام. |
| `inactive` | موقوف مؤقتاً. |
| `suspended` | موقوف إدارياً. |

### 3.3 Company Approval Status

| القيمة | المعنى |
|---|---|
| `pending` | بانتظار موافقة الأدمن. |
| `approved` | الشركة مقبولة. |
| `rejected` | الشركة مرفوضة. |
| `suspended` | الشركة موقوفة. |

### 3.4 Job Status

| القيمة المثالية للـ MVP | الموجود حالياً غالباً | ملاحظة |
|---|---|---|
| `draft` | `draft` | قبل النشر. |
| `published` | `open` | يجب التوحيد: إما يعتمد الفرونت `open` أو نغيرها إلى `published`. |
| `closed` | `closed` | لا يقبل تقديمات جديدة. |

### 3.5 Application Status

| القيمة | نهائية؟ | من يغيّرها غالباً |
|---|---:|---|
| `submitted` | لا | System عند التقديم |
| `under_review` | لا | Employer |
| `shortlisted` | لا | Employer |
| `need_more_information` | لا | Employer/System |
| `on_hold` | لا | Employer |
| `test_pending` | لا | Employer/System عند إسناد اختبار |
| `test_completed` | لا | System/Employer بعد تسليم/تقييم الاختبار |
| `interview_pending` | لا | Employer |
| `interview_scheduled` | لا | Employer/System عند جدولة مقابلة |
| `interview_completed` | لا | Employer/System |
| `final_review` | لا | Employer/System بعد التقييم |
| `accepted` | نعم | Employer |
| `rejected` | نعم | Employer |
| `withdrawn` | نعم | Job Seeker |

### 3.6 Interview Enums

| النوع | القيم |
|---|---|
| `interview_type` | `hr`, `technical`, `final` |
| `interview_mode` | `online`, `on_site` |
| `interview_status` المطلوب مستقبلاً | `scheduled`, `confirmed`, `rescheduled`, `completed`, `cancelled`, `no_show`, `evaluated` |

---

## 4. APIs المصادقة والحسابات

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required Body | Optional Body | Response Data | ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| ✅ | POST | `/auth/register/job-seeker` | Auth API | Public | UC-AUTH-01 | `name`, `email`, `password`, `password_confirmation` | `phone`, `terms_accepted` مطلوب منطقياً إذا أضيف | `user`, `job_seeker_profile` وربما `token` إذا اختير تسجيل دخول مباشر | بعد النجاح يوجه المستخدم إلى Profile/CV upload. |
| ✅ | POST | `/auth/register/employer` | Auth API | Public | UC-AUTH-02 | `name`, `email`, `company_name`, `password`, `password_confirmation` | `phone`, `company_website`, `company_size`, `terms_accepted` | `user`, `employer_profile`, `company` | الشركة تكون `pending` حتى موافقة الأدمن. |
| ✅ | POST | `/auth/login` | Auth API | Public | UC-AUTH-03 | `email`, `password` | `remember_me` | `token`, `token_type`, `user` | الفرونت يحفظ token ويوجه حسب role. |
| ✅ | GET | `/auth/me` | Auth API | Any authenticated | UC-AUTH-03 | لا يوجد | لا يوجد | بيانات المستخدم مع البروفايل حسب الدور | يستخدم عند refresh للتأكد من الجلسة. |
| ✅ | POST | `/auth/logout` | Auth API | Any authenticated | UC-AUTH-03 | لا يوجد | لا يوجد | success message | يمسح الفرونت token بعد النجاح. |
| ⬜ | POST | `/auth/forgot-password` | Auth API | Public | UC-AUTH-04 | `email` | لا يوجد | success message | مطلوب للـ MVP إذا كان سيتم عرض شاشة نسيان كلمة المرور. |
| ⬜ | POST | `/auth/reset-password` | Auth API | Public | UC-AUTH-04 | `email`, `token/code`, `password`, `password_confirmation` | لا يوجد | success message | يمكن تأجيله إن لم توجد Email delivery. |
| ⬜ | POST | `/auth/change-password` | Auth API | Any authenticated | تحسين أمني | `current_password`, `password`, `password_confirmation` | لا يوجد | success message | مفيد من صفحة الإعدادات. |

---

## 5. APIs Job Seeker Profile

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required Body | Optional Body / Query | Response Data | ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| ✅ | GET | `/profile` | Profile API | Job Seeker | UC-JS-01/02 | لا يوجد | لا يوجد | `job_seeker_profile` مع `user`, `experiences`, `education`, `skills` | شاشة Profile الرئيسية. |
| 🟡 | PUT | `/profile` | Profile API | Job Seeker | UC-JS-02 | لا يوجد لأن التعديل جزئي | `headline`, `summary`, `phone`, `location`, `portfolio_url`, `linkedin_url`, `github_url` | updated profile | ينقص حقول مثل `expected_salary`, `availability_date`, `years_of_experience`, و `source_type` إن أردنا مطابقة الوثيقة الأصلية. |
| ✅ | GET | `/profile/experiences` | Profile API | Job Seeker | UC-JS-03 | لا يوجد | لا يوجد | list of experiences | يعرض خبرات المستخدم فقط. |
| 🟡 | POST | `/profile/experiences` | Profile API | Job Seeker | UC-JS-03 | `title`, `company_name`, `start_date` | `location`, `end_date`, `is_current`, `description` | created experience | ينقص `source_type` إذا أردنا تتبع manual/cv_parsed. |
| ✅ | GET | `/profile/experiences/{experience}` | Profile API | Owner Job Seeker | UC-JS-03 | لا يوجد | لا يوجد | experience | محمي بملكية الخبرة. |
| 🟡 | PUT/PATCH | `/profile/experiences/{experience}` | Profile API | Owner Job Seeker | UC-JS-03 | لا يوجد | نفس حقول الإنشاء جزئياً | updated experience | يجب منع تعديل خبرة لا يملكها المستخدم. |
| ✅ | DELETE | `/profile/experiences/{experience}` | Profile API | Owner Job Seeker | UC-JS-03 | لا يوجد | لا يوجد | success message | حذف خبرة من البروفايل. |
| ✅ | GET | `/profile/education` | Profile API | Job Seeker | UC-JS-04 | لا يوجد | لا يوجد | list of education | يعرض تعليم المستخدم فقط. |
| 🟡 | POST | `/profile/education` | Profile API | Job Seeker | UC-JS-04 | `institution`, `degree` | `field_of_study`, `start_date`, `end_date`, `description` | created education | ينقص `graduation_year` كحقل واضح إذا اعتمدناه في الواجهة. |
| ✅ | GET | `/profile/education/{education}` | Profile API | Owner Job Seeker | UC-JS-04 | لا يوجد | لا يوجد | education | محمي بالملكية. |
| 🟡 | PUT/PATCH | `/profile/education/{education}` | Profile API | Owner Job Seeker | UC-JS-04 | لا يوجد | نفس حقول الإنشاء جزئياً | updated education | يفضل توحيد أسماء الحقول مع الفرونت. |
| ✅ | DELETE | `/profile/education/{education}` | Profile API | Owner Job Seeker | UC-JS-04 | لا يوجد | لا يوجد | success message | حذف سجل تعليم. |
| 🟡 | POST | `/profile/skills` | Profile API | Job Seeker | UC-JS-05 | `skill_id` | لا يوجد | updated profile with skills | ينقص `level`, `years_used` إن أردنا تقييم أدق. |
| ✅ | DELETE | `/profile/skills/{skill}` | Profile API | Job Seeker | UC-JS-05 | لا يوجد | لا يوجد | updated profile with skills | إزالة مهارة من بروفايل المرشح. |
| ⬜ | GET | `/profile/completeness` | Profile API | Job Seeker | UC-JS-01 | لا يوجد | لا يوجد | `percentage`, `missing_sections`, `recommended_actions` | مفيد للداشبورد؛ يمكن حسابه فرونت مؤقتاً لكن الأفضل Backend. |
| ⬜ | GET | `/profile/public-preview` | Profile API | Job Seeker | UC-EMP-08 | لا يوجد | لا يوجد | نسخة القراءة التي ستراها الشركة | يفيد المرشح لمعرفة ما سيظهر عند التقديم. |

---

## 6. APIs Skills Catalog

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required | Optional | Response Data | ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| ✅ | GET | `/skills` | Reference API | Public | UC-JS-05/UC-ADM-03 | لا يوجد | `search`, `limit` | list of skills | يستخدم في autocomplete عند البروفايل والوظائف. |
| ⬜ | GET | `/skill-categories` | Reference API | Public/Admin | UC-ADM-03 | لا يوجد | `search`, `status` | list of categories | غير ضروري إذا لم نعتمد categories في MVP. |

---

## 7. APIs Employer Company & Employer Profile

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required Body | Optional Body | Response Data | ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| ✅ | GET | `/company` | Company API | Employer | UC-EMP-01 | لا يوجد | لا يوجد | company | يعرض شركة الـ employer الحالي. |
| 🟡 | PUT | `/company` | Company API | Employer | UC-EMP-01 | لا يوجد | `name`, `industry`, `website`, `location`, `description` | updated company | ينقص `logo`, وربما `company_size`. |
| ✅ | GET | `/employer/profile` | Employer API | Employer | UC-EMP-01 | لا يوجد | لا يوجد | employer profile with company | يعرض بروفايل HR/Employer. |
| ✅ | PUT | `/employer/profile` | Employer API | Employer | UC-EMP-01 | لا يوجد | `job_title`, `phone`, `bio` | updated employer profile | لإعدادات حساب صاحب العمل. |
| ⬜ | POST | `/company/logo` | Company API | Employer | UC-EMP-01 | multipart `logo` | لا يوجد | updated company | مطلوب إذا الواجهة تعرض شعار الشركة. |
| ⬜ | GET | `/company/public/{company}` | Public Company API | Public | UC-VIS-03 | `company_id` in URL | لا يوجد | public company profile | اختياري لصفحة الشركة العامة. |

---

## 8. APIs CV Management & Parsing

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required Body | Optional Body / Query | Response Data | Side Effects / ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| ✅ | GET | `/cv` | CV API | Job Seeker | UC-JS-06/09/12 | لا يوجد | `per_page` | paginated CV files | يعرض نسخ CV التي رفعها المستخدم. |
| 🟡 | POST | `/cv/upload` | CV API | Job Seeker | UC-JS-06/09 | multipart `file` PDF/DOCX max 5MB تقريباً | `version_label`, `make_primary` غير موجودة حالياً | created `cv_file` status=`uploaded` | يبدأ parsing عبر Job. ينقص version label وprimary CV. |
| ✅ | GET | `/cv/{cvFile}` | CV API | Owner Job Seeker | UC-JS-06/09 | `cvFile` in URL | لا يوجد | CV metadata | لمعرفة status: uploaded/processing/parsed/failed. |
| ✅ | GET | `/cv/{cvFile}/parsed` | CV API | Owner Job Seeker | UC-JS-07 | `cvFile` in URL | لا يوجد | `raw_text`, `parsed_json` | شاشة مراجعة البيانات المستخرجة. |
| 🟡 | POST | `/cv/{cvFile}/confirm` | CV API | Owner Job Seeker | UC-JS-08 | `cvFile` in URL | حالياً غالباً بدون body | updated profile | يؤكد كامل البيانات مرة واحدة. ينقص قبول/رفض/تعديل كل قسم أو كل حقل. |
| ⬜ | PATCH | `/cv/{cvFile}/review` | CV Review API | Owner Job Seeker | UC-JS-07/08 | `sections` أو `decisions[]` | `edited_values` | draft preview | مطلوب لجعل المراجعة granular قبل confirm. |
| ⬜ | POST | `/cv/{cvFile}/make-primary` | CV API | Owner Job Seeker | UC-JS-12 | لا يوجد | لا يوجد | updated CV list | لتحديد CV المستخدم افتراضياً في التقديمات. |
| ⬜ | DELETE | `/cv/{cvFile}` | CV API | Owner Job Seeker | إدارة CV | لا يوجد | لا يوجد | success message | حذف نسخة CV، مع منع حذف CV مستخدم في طلبات نشطة إن لزم. |
| ⬜ | GET | `/cv/{cvFile}/download` | CV API | Owner/Related Employer | UC-EMP-08 | لا يوجد | لا يوجد | file response/signed URL | الشركة تحتاج رؤية CV المرتبط بالتقديم. |
| ⬜ | GET | `/cv/{cvFile}/suggestions` | Profile Sync API | Owner Job Seeker | UC-JS-09/10 | `cvFile` in URL | لا يوجد | list of change suggestions | Smart Profile Sync عند رفع CV جديد. |
| ⬜ | POST | `/profile/suggestions/{suggestion}/decision` | Profile Sync API | Owner Job Seeker | UC-JS-11 | `decision`: accept/reject/edit | `edited_value` | applied/rejected suggestion | لا يطبق أي اقتراح بدون موافقة المرشح. |
| ⬜ | POST | `/profile/suggestions/apply-bulk` | Profile Sync API | Owner Job Seeker | UC-JS-11 | `suggestion_ids[]`, `decision` | لا يوجد | updated profile | اختياري لتسهيل Accept All. |

---

## 9. APIs Job Posting — Public & Employer

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required Body | Optional Body / Query | Response Data | ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| ✅ | GET | `/jobs` | Public Jobs API | Public | UC-VIS-01/02 | لا يوجد | `search`, `location`, `skill`, `experience_level`, `per_page` | paginated open jobs | صفحة الوظائف العامة. |
| ✅ | GET | `/jobs/{jobPosting}` | Public/Protected Job API | Public for open / employer for own non-open | UC-VIS-03 | `jobPosting` in URL | لا يوجد | job details | يفتح تفاصيل الوظيفة. |
| 🟡 | POST | `/jobs` | Employer Job API | Employer | UC-EMP-02 | `title`, `description`, `employment_type`, `experience_level`, `location` | `salary_min`, `salary_max` | created draft job | ينقص `work_mode`, `requirements`, `responsibilities`, `deadline`, `department`, `education_requirement`. |
| ✅ | GET | `/jobs/my` | Employer Job API | Employer | UC-EMP-02/04/05 | لا يوجد | `search`, `location`, `skill`, `experience_level`, `per_page` | paginated company jobs | قائمة وظائف الشركة. |
| 🟡 | PUT | `/jobs/{jobPosting}` | Employer Job API | Owning Employer | UC-EMP-04 | لا يوجد | نفس حقول الإنشاء جزئياً | updated job | يفضل منع تعديل حقول حساسة بعد وجود طلبات إلا حسب قرار المشروع. |
| ✅ | DELETE | `/jobs/{jobPosting}` | Employer Job API | Owning Employer | إدارة وظائف | لا يوجد | لا يوجد | success message | حذف الوظيفة. يفضل soft delete أو منع الحذف إذا يوجد applications. |
| ✅ | POST | `/jobs/{jobPosting}/skills` | Employer Job API | Owning Employer | UC-EMP-02/04 | `skill_ids[]` | لا يوجد | updated job with skills | يستخدم بعد إنشاء الوظيفة أو ضمن الفورم. |
| ✅ | DELETE | `/jobs/{jobPosting}/skills/{skill}` | Employer Job API | Owning Employer | UC-EMP-04 | لا يوجد | لا يوجد | updated job with skills | حذف مهارة من الوظيفة. |
| ⚠️ | POST | `/jobs/{jobPosting}/publish` | Employer Job API | Owning Employer | UC-EMP-03 | لا يوجد | لا يوجد | job status=`open` | السيناريو يقول `Published`، والكود يبدو يستخدم `open`. يجب توحيد naming مع الفرونت. |
| ✅ | POST | `/jobs/{jobPosting}/close` | Employer Job API | Owning Employer | UC-EMP-05 | لا يوجد | `reason` غير ظاهر حالياً | job status=`closed` | يمنع تقديمات جديدة ويبقي السابقة. |
| ⬜ | POST | `/jobs/{jobPosting}/reopen` | Employer Job API | Owning Employer | إدارة وظائف | لا يوجد | لا يوجد | job status=`open/published` | اختياري إذا أردنا إعادة فتح وظيفة. |
| ⬜ | GET | `/jobs/{jobPosting}/preview` | Employer Job API | Owning Employer | UC-EMP-02 | لا يوجد | لا يوجد | public preview object | يساعد قبل النشر. |
| ⬜ | POST | `/jobs/{jobPosting}/screening-questions` | Employer Job API | Owning Employer | UC-APP-01 | `questions[]` | لا يوجد | updated questions | مطلوب إذا أردنا screening questions. |
| ⬜ | PUT | `/jobs/{jobPosting}/screening-questions/{question}` | Employer Job API | Owning Employer | UC-APP-01 | لا يوجد | `question`, `type`, `is_required`, `options[]` | updated question | اختياري للـ MVP. |
| ⬜ | DELETE | `/jobs/{jobPosting}/screening-questions/{question}` | Employer Job API | Owning Employer | UC-APP-01 | لا يوجد | لا يوجد | success message | اختياري للـ MVP. |

---

## 10. APIs Applications Workflow

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required Body | Optional Body / Query | Response Data | Side Effects / ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| 🟡 | POST | `/jobs/{jobPosting}/applications` | Application API | Job Seeker | UC-APP-01/02 | `jobPosting` in URL | حالياً لا يظهر body؛ المطلوب مستقبلاً: `selected_cv_id`, `consent`, `cover_letter`, `screening_answers[]` | created application status=`submitted` | يمنع التكرار. ينقص ربط CV/cover letter/consent حسب السيناريو. |
| 🟡 | POST | `/applications/{jobPosting}` | Application API | Job Seeker | UC-APP-01/02 | `jobPosting` in URL | نفس الملاحظة | created application | مسار بديل؛ يفضل اعتماد المسار nested فقط لتقليل الالتباس. |
| ✅ | GET | `/applications/my` | Application API | Job Seeker | UC-APP-03 | لا يوجد | `per_page`, ويفضل `status` لاحقاً | paginated applications | شاشة My Applications. |
| ✅ | GET | `/applications/{jobApplication}` | Application API | Applicant or owning employer | UC-APP-03/EMP-08 | `jobApplication` in URL | لا يوجد | application with status/history/job/profile | صفحة تفاصيل الطلب. |
| ✅ | POST | `/applications/{jobApplication}/withdraw` | Application API | Applicant Job Seeker | UC-APP-04 | لا يوجد | `note`/`reason` | updated application status=`withdrawn` | لا يسمح بعد accepted/rejected. |
| ✅ | GET | `/jobs/{jobPosting}/applications` | Employer Application API | Owning Employer | UC-EMP-06/07 | `jobPosting` in URL | `per_page`، مطلوب مستقبلاً: `status`, `search`, `score_min`, `skill` | paginated applications | Pipeline طلبات وظيفة معينة. |
| 🟡 | POST | `/applications/{jobApplication}/status` | Workflow API | Owning Employer | UC-EMP-09/10/11/12/13/FINAL | `status` | `note` | updated application + history | endpoint عام. يفضل إضافة endpoints مخصصة للأحداث المهمة أو توثيق status values بدقة. |
| ⬜ | GET | `/applications/{jobApplication}/history` | Workflow API | Applicant or owning employer | UC-APP-03 | لا يوجد | لا يوجد | status history timeline | يمكن أن يكون مضمن داخل show، لكن endpoint مستقل أسهل للفرونت. |
| ⬜ | POST | `/applications/{jobApplication}/request-info` | Workflow API | Owning Employer | UC-EMP-12 | `message`, `requested_items[]` | `due_date` | application status=`need_more_information` | أفضل من status العام لأن له body خاص. |
| ⬜ | POST | `/applications/{jobApplication}/submit-requested-info` | Workflow API | Applicant Job Seeker | UC-APP-05 | حسب requested items | `response_message`, `attachments[]` | application status back to `under_review` | مطلوب لإغلاق دورة Need More Information. |
| ⬜ | POST | `/applications/{jobApplication}/notes` | Employer Notes API | Owning Employer | UC-EMP-14 | `note` | `visibility`, `tag` | created internal note | لا يظهر للمرشح. |
| ⬜ | GET | `/applications/{jobApplication}/notes` | Employer Notes API | Owning Employer | UC-EMP-14 | لا يوجد | لا يوجد | list of notes | ملاحظات داخلية للـ HR. |
| ⬜ | POST | `/applications/{jobApplication}/final-decision` | Workflow API | Owning Employer | UC-FINAL-01/02 | `decision`: accepted/rejected | `internal_reason`, `candidate_message`, `offer_note`, `start_date` | updated final application | أو يستخدم `/status` لكن endpoint خاص أوضح للفرونت والـ Audit. |
| ⬜ | GET | `/employer/applications` | Employer Application API | Employer | UC-EMP-06/07 | لا يوجد | `job_id`, `status`, `search`, `per_page`, `score_min`, `score_max` | cross-job pipeline | مفيد لداشبورد الشركة العام. |

---

## 11. APIs Tests Module

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required Body | Optional Body / Query | Response Data | Side Effects / ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| ✅ | GET | `/tests` | Test Catalog API | Employer/Admin/Job Seeker | UC-TEST-01/03 | لا يوجد | `per_page` | paginated tests | Job seeker يرى active فقط. |
| 🟡 | POST | `/tests` | Test Catalog API | Employer/Admin | UC-TEST-01 | `title` | `description`, `instructions`, `duration_minutes`, `max_score`, `passing_score`, `is_active` | created test | لا توجد أسئلة داخلية ككيانات مستقلة حالياً. |
| ✅ | GET | `/tests/{test}` | Test Catalog API | Employer/Admin/Job Seeker | UC-TEST-01/03 | `test` in URL | لا يوجد | test details | يعرض تعليمات الاختبار. |
| 🟡 | PUT/PATCH | `/tests/{test}` | Test Catalog API | Employer/Admin | UC-TEST-01 | لا يوجد | نفس حقول الإنشاء جزئياً | updated test | إذا أصبح للاختبار أسئلة، يلزم فصل questions. |
| ✅ | DELETE | `/tests/{test}` | Test Catalog API | Employer/Admin | UC-TEST-01 | لا يوجد | لا يوجد | success message | يفضل منع الحذف إذا مستخدم في assignments أو استخدام soft delete. |
| 🟡 | POST | `/applications/{jobApplication}/assign-test` | Test Assignment API | Owning Employer | UC-TEST-02 | `test_id` | `note`, مطلوب مستقبلاً: `deadline`, `instructions` | assignment, application status=`test_pending` | ينقص deadline. |
| ✅ | GET | `/applications/{jobApplication}/tests` | Test Assignment API | Owning Employer | UC-TEST-06 | `jobApplication` in URL | لا يوجد | assignments list | تبويب Tests داخل Candidate Profile. |
| ✅ | GET | `/my/tests` | Test Assignment API | Job Seeker | UC-TEST-03 | لا يوجد | `per_page` | paginated assigned tests | Test Center للمرشح. |
| ✅ | POST | `/tests/{applicationTestAssignment}/start` | Test Attempt API | Assigned Job Seeker | UC-TEST-04 | assignment in URL | لا يوجد | created attempt | يبدأ attempt. |
| 🟡 | POST | `/tests/{applicationTestAssignment}/submit` | Test Attempt API | Assigned Job Seeker | UC-TEST-05 | `answers` array | لا يوجد | submitted attempt | لا توجد validation تفصيلية للأسئلة إذا لم تنفذ question model. |
| ✅ | POST | `/tests/{testAttempt}/evaluate` | Test Attempt API | Owning Employer | UC-TEST-07 | `score` | `feedback` | evaluated attempt + status=`test_completed` | score لا يخزن داخل JobApplication بل داخل attempt. |
| ⬜ | POST | `/tests/{test}/questions` | Test Question API | Employer/Admin | UC-TEST-01 | `type`, `question_text` | `options[]`, `correct_answer`, `points`, `sort_order` | created question | مطلوب إذا أردنا اختبار داخلي حقيقي وليس answers JSON فقط. |
| ⬜ | PUT | `/tests/{test}/questions/{question}` | Test Question API | Employer/Admin | UC-TEST-01 | لا يوجد | نفس حقول الإنشاء | updated question | اختياري حسب وقت المشروع. |
| ⬜ | DELETE | `/tests/{test}/questions/{question}` | Test Question API | Employer/Admin | UC-TEST-01 | لا يوجد | لا يوجد | success message | اختياري حسب وقت المشروع. |
| ⬜ | GET | `/test-attempts/{testAttempt}` | Test Attempt API | Applicant/Owning Employer | UC-TEST-06 | attempt in URL | لا يوجد | attempt details | مفيد بدل الاعتماد فقط على assignment list. |

---

## 12. APIs Interviews Module

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required Body | Optional Body / Query | Response Data | Side Effects / ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| 🟡 | POST | `/applications/{jobApplication}/interviews` | Interview API | Owning Employer | UC-INT-02 | `interview_type`, `scheduled_at`, `duration_minutes`, `interview_mode` + `meeting_link` إذا online أو `location` إذا on-site | `note` | created interview, application status=`interview_scheduled` | السيناريو المطلوب يستخدم start/end؛ الحالي يستخدم scheduled_at + duration. مقبول لكن يجب توثيقه للفرونت. |
| ✅ | GET | `/applications/{jobApplication}/interviews` | Interview API | Owning Employer | UC-INT-02/07 | لا يوجد | لا يوجد | interviews list | تبويب المقابلات في Candidate Profile. |
| 🟡 | PUT | `/interviews/{interview}` | Interview API | Owning Employer | UC-INT-03 | لا يوجد | نفس حقول الإنشاء | updated interview | يمثل reschedule لكن لا يبدو هناك status `rescheduled`. |
| 🟡 | DELETE | `/interviews/{interview}` | Interview API | Owning Employer | UC-INT-04 | لا يوجد | `reason` غير ظاهر حالياً | success message | يمثل cancel/delete؛ الأفضل endpoint cancel يحفظ السبب. |
| ✅ | POST | `/interviews/{interview}/complete` | Interview API | Owning Employer | UC-INT-07 | لا يوجد | `completion_note` | interview completed, application status=`interview_completed` | بعد المقابلة وقبل التقييم. |
| 🟡 | POST | `/interviews/{interview}/evaluate` | Interview Evaluation API | Owning Employer | UC-INT-07/08 | `recommendation`, `items[].criterion`, `items[].score` | `overall_comment`, `items[].comment` | interview with evaluation, application status=`final_review` | يفضل تثبيت criteria الخمسة: communication, technical, problem_solving, job_fit, professionalism. |
| ✅ | GET | `/my/interviews` | Interview API | Job Seeker | UC-INT-05 | لا يوجد | `per_page` | paginated interviews | شاشة مقابلات المرشح. |
| ✅ | GET | `/interviews/{interview}` | Interview API | Applicant or owning employer | UC-INT-05 | interview in URL | لا يوجد | interview details | يعرض الرابط/الموقع والوقت. |
| ⬜ | POST | `/interviews/{interview}/confirm` | Interview API | Applicant Job Seeker | UC-INT-06 | `confirm`: true/false | `note` | interview status=`confirmed/declined` | مطلوب إذا أردنا تأكيد حضور المرشح. |
| ⬜ | POST | `/interviews/{interview}/cancel` | Interview API | Owning Employer | UC-INT-04 | `reason` | `message_to_candidate` | interview status=`cancelled` | أفضل من DELETE للحفاظ على السجل. |
| ⬜ | POST | `/interviews/{interview}/no-show` | Interview API | Owning Employer | إدارة مقابلات | لا يوجد | `note` | status=`no_show` | اختياري. |

---

## 13. APIs Matching / AI Assistance

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required | Optional | Response Data | ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| 🟡 | GET | `/jobs/recommended` | Matching API | Job Seeker | AI-04/UC-JS-01 | لا يوجد | `limit` 1-50 | jobs with `score`, `breakdown`, `matched_skills` | منجز deterministic TF-IDF/cosine، ليس AI عميق. جيد للمشروع. |
| 🟡 | GET | `/jobs/{jobPosting}/candidates/ranked` | Matching API | Owning Employer | AI-05/UC-EMP-06/08 | jobPosting in URL | `limit` 1-50 | ranked candidates with score/breakdown/profile | مناسب للـ HR. يجب التأكيد أنه مساعد لا قرار. |
| ⬜ | GET | `/applications/{jobApplication}/match-score` | Matching API | Applicant or owning employer | AI-05 | application in URL | لا يوجد | score breakdown | مفيد في صفحة تفاصيل الطلب. قد يكون مضمن حالياً في ranked فقط. |
| ⬜ | GET | `/applications/{jobApplication}/cv-summary` | AI Summary API | Owning Employer | AI-06/UC-EMP-08 | application in URL | لا يوجد | `summary`, `highlights`, `risks`, `generated_at` | يمكن تنفيذه rule-based أو LLM لاحقاً. |
| ⬜ | GET | `/interviews/{interview}/suggested-questions` | AI Suggestions API | Owning Employer | AI-07 | interview in URL | `limit`, `focus_area` | questions list with reason | Future/MVP+؛ لا تنفذ AI Interview Bot. |
| ⬜ | POST | `/jobs/{jobPosting}/recalculate-matching` | Matching Admin/Employer API | Owning Employer/Admin | AI-05 | لا يوجد | لا يوجد | recalculation job/status | مفيد بعد تعديل job/profile. |

---

## 14. APIs Notifications

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required | Optional | Response Data | ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| ✅ | GET | `/notifications` | Notification API | Any authenticated | UC-APP-06 | لا يوجد | `per_page`, `type`, `read` مستقبلاً | paginated notifications | Notification Center. |
| ✅ | GET | `/notifications/unread-count` | Notification API | Any authenticated | UC-APP-06 | لا يوجد | لا يوجد | `{count}` | Badge في الهيدر. |
| ✅ | POST | `/notifications/{notification}/read` | Notification API | Owner | UC-APP-06 | notification in URL | لا يوجد | updated notification | Mark as read. |
| ⬜ | POST | `/notifications/read-all` | Notification API | Any authenticated | UC-APP-06 | لا يوجد | لا يوجد | count/updated | مطلوب لتجربة استخدام أفضل. |
| ⬜ | DELETE | `/notifications/{notification}` | Notification API | Owner | UC-APP-06 | لا يوجد | لا يوجد | success message | اختياري. |
| ⬜ | GET | `/admin/notification-templates` | Admin Notification API | Admin | UC-ADM-06 | لا يوجد | `trigger`, `channel` | templates list | مطلوب إذا ستوجد شاشة قوالب إشعارات. |
| ⬜ | POST | `/admin/notification-templates` | Admin Notification API | Admin | UC-ADM-06 | `trigger`, `channel`, `subject`, `body` | `is_active` | created template | يمكن تأجيله والاكتفاء بقوالب ثابتة في الكود. |
| ⬜ | PUT | `/admin/notification-templates/{template}` | Admin Notification API | Admin | UC-ADM-06 | لا يوجد | نفس حقول الإنشاء | updated template | اختياري. |

---

## 15. APIs Admin Dashboard

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required Body | Optional Body / Query | Response Data | ملاحظات للفرونت |
|---|---|---|---|---|---|---|---|---|---|
| ✅ | GET | `/admin/users` | Admin API | Admin | UC-ADM-01 | لا يوجد | `role`, `status`, `search`, `per_page` | paginated users | إدارة المستخدمين. |
| ✅ | GET | `/admin/users/{user}` | Admin API | Admin | UC-ADM-01 | user in URL | لا يوجد | user details | تفاصيل المستخدم. |
| ✅ | PATCH | `/admin/users/{user}/role` | Admin API | Admin | UC-ADM-01 | `role` | لا يوجد | updated user | يجب حماية آخر admin من تغيير دوره إن لزم. |
| ✅ | PATCH | `/admin/users/{user}/status` | Admin API | Admin | UC-ADM-01 | `status` | `reason` غير ظاهر حالياً | updated user | تفعيل/إيقاف المستخدم. |
| ✅ | GET | `/admin/companies` | Admin API | Admin | UC-ADM-02 | لا يوجد | `approval_status`, `search`, `per_page` | paginated companies | قائمة الشركات للمراجعة. |
| ✅ | PATCH | `/admin/companies/{company}/approve` | Admin API | Admin | UC-ADM-02 | لا يوجد | `admin_note` غير ظاهر حالياً | updated company | اعتماد الشركة. |
| 🟡 | PATCH | `/admin/companies/{company}/reject` | Admin API | Admin | UC-ADM-02 | لا يوجد | `admin_note` | updated company | موجود، لكن يجب التأكد من حفظ سبب الرفض. |
| ⬜ | PATCH | `/admin/companies/{company}/suspend` | Admin API | Admin | UC-ADM-02 | لا يوجد | `admin_note` | updated company | مطلوب لأن enum يتضمن suspended. |
| ✅ | GET | `/admin/skills` | Admin API | Admin | UC-ADM-03 | لا يوجد | `search`, `per_page` | skills list | إدارة المهارات. |
| ✅ | POST | `/admin/skills` | Admin API | Admin | UC-ADM-03 | `name` | `aliases`, `status` غير ظاهرين حالياً | created skill | ينقص `name_ar/name_en/status` إذا أردنا taxonomy أقوى. |
| ✅ | PUT | `/admin/skills/{skill}` | Admin API | Admin | UC-ADM-03 | لا يوجد | `name` | updated skill | تعديل مهارة. |
| ✅ | DELETE | `/admin/skills/{skill}` | Admin API | Admin | UC-ADM-03 | لا يوجد | لا يوجد | success message | يفضل منع الحذف إذا مستخدمة أو soft delete. |
| ✅ | GET | `/admin/tests` | Admin API | Admin | UC-TEST-01 | لا يوجد | `per_page` | tests list | إدارة الاختبارات من الأدمن. |
| ✅ | POST | `/admin/tests` | Admin API | Admin | UC-TEST-01 | `title` | `description`, `instructions`, `duration_minutes`, `max_score`, `passing_score`, `is_active` | created test | نفس Test catalog. |
| ✅ | PUT | `/admin/tests/{test}` | Admin API | Admin | UC-TEST-01 | لا يوجد | test fields | updated test | تعديل اختبار. |
| ✅ | DELETE | `/admin/tests/{test}` | Admin API | Admin | UC-TEST-01 | لا يوجد | لا يوجد | success message | حذف اختبار. |
| ⬜ | GET | `/admin/reports/overview` | Admin Reports API | Admin | UC-ADM-05 | لا يوجد | `from`, `to` | counts: users/jobs/applications/companies | مطلوب للوحة تقارير بسيطة. |
| ⬜ | GET | `/admin/reports/applications` | Admin Reports API | Admin | UC-ADM-05 | لا يوجد | `from`, `to`, `company_id`, `status` | application stats | اختياري للعرض أمام اللجنة. |
| ⬜ | GET | `/admin/audit-logs` | Admin Audit API | Admin | UC-SYS-11 | لا يوجد | `actor_id`, `entity_type`, `action`, `from`, `to`, `per_page` | paginated audit logs | مطلوب إذا أردنا Audit واضح. |

---

## 16. APIs Audit Logs المطلوبة

| الحالة | Method | Endpoint | النوع | Auth/Role | Use Case | Required | Optional | Response Data | ملاحظات |
|---|---|---|---|---|---|---|---|---|---|
| ⬜ | GET | `/admin/audit-logs` | Audit API | Admin | UC-SYS-11 | لا يوجد | filters | paginated audit logs | غير ظاهر كـ endpoint حالياً، والتدقيق مهم جداً للمشروع. |
| ⬜ | GET | `/admin/audit-logs/{auditLog}` | Audit API | Admin | UC-SYS-11 | audit id | لا يوجد | audit detail with before/after | مفيد للمناقشة أمام اللجنة. |

### الأحداث التي يجب تسجيلها في AuditLog

| الحدث | actor | entity | before/after |
|---|---|---|---|
| إنشاء/تعديل/حذف وظيفة | employer | job_posting | نعم |
| نشر/إغلاق وظيفة | employer | job_posting | نعم |
| رفع CV ونتيجة parsing | job_seeker/system | cv_file/cv_parsing_result | نعم |
| تأكيد بيانات parsed CV | job_seeker | profile | نعم |
| إنشاء طلب توظيف | job_seeker | job_application | نعم |
| أي تغيير حالة Application | employer/job_seeker/system | job_application | نعم |
| إسناد/تقييم اختبار | employer | test_assignment/test_attempt | نعم |
| جدولة/تقييم مقابلة | employer | interview/interview_evaluation | نعم |
| قرار قبول/رفض نهائي | employer | job_application | نعم |
| موافقة/رفض شركة | admin | company | نعم |

---

## 17. APIs غير موجودة لكنها مهمة لإغلاق فجوات الـ MVP

هذه ليست كلها ضرورية في أول Sprint، لكنها أهم الفجوات التي سيشعر بها فريق الفرونت أثناء بناء الواجهات.

| الأولوية | الحالة | API | لماذا مهم؟ | المرحلة المقترحة |
|---|---|---|---|---|
| عالية | ⬜ | `/auth/forgot-password`, `/auth/reset-password` | شاشة login عادة تحتاجها. | Phase 1 تحسين |
| عالية | ⬜ | `/cv/{cvFile}/suggestions`, `/profile/suggestions/...` | Smart Profile Sync مذكور بوضوح في النطاق. | Phase 3 |
| عالية | 🟡 | Apply body: `selected_cv_id`, `consent`, `cover_letter` | التقديم بدون CV/consent أقل واقعية للفريق. | Phase 5 |
| عالية | ⬜ | `/applications/{id}/request-info` و submit requested info | يغلق حالة Need More Information بشكل صحيح. | Phase 5 |
| عالية | ⬜ | Audit logs | من متطلبات الدفاع والتتبع. | Phase 9 |
| متوسطة | ⬜ | Internal notes | مهم للـ Employer Dashboard. | Phase 5 |
| متوسطة | ⬜ | Admin reports overview | مفيد للعرض أمام اللجنة. | Phase 10 |
| متوسطة | ⬜ | Interview confirm/cancel endpoints | يعطي دورة مقابلة أوضح. | Phase 7 |
| متوسطة | ⬜ | CV download/signed URL | الشركة تحتاج عرض CV الأصلي. | Phase 3/5 |
| منخفضة | ⬜ | Test questions CRUD | إذا الوقت يسمح لجعل الاختبار داخلياً كاملاً. | Phase 6 |
| منخفضة | ⬜ | Notification templates | يمكن استبداله بقوالب ثابتة في الكود. | Phase 9/10 |

---

## 18. Minimum API Set المقترح قبل تسليم نسخة Frontend أولى

إذا أراد فريق الفرونت البدء دون انتظار كل شيء، هذه أقل مجموعة مستقرة:

### Job Seeker App

| API | الحالة |
|---|---|
| `POST /auth/register/job-seeker` | ✅ |
| `POST /auth/login` | ✅ |
| `GET /auth/me` | ✅ |
| `GET/PUT /profile` | ✅/🟡 |
| `GET/POST/PUT/DELETE /profile/experiences` | ✅/🟡 |
| `GET/POST/PUT/DELETE /profile/education` | ✅/🟡 |
| `GET /skills`, `POST/DELETE /profile/skills` | ✅/🟡 |
| `GET /cv`, `POST /cv/upload`, `GET /cv/{id}/parsed`, `POST /cv/{id}/confirm` | ✅/🟡 |
| `GET /jobs`, `GET /jobs/{id}`, `GET /jobs/recommended` | ✅/🟡 |
| `POST /jobs/{id}/applications`, `GET /applications/my`, `GET /applications/{id}`, `POST /applications/{id}/withdraw` | ✅/🟡 |
| `GET /my/tests`, `POST /tests/{assignment}/start`, `POST /tests/{assignment}/submit` | ✅/🟡 |
| `GET /my/interviews`, `GET /interviews/{id}` | ✅ |
| `GET /notifications`, `GET /notifications/unread-count`, `POST /notifications/{id}/read` | ✅ |

### Employer Dashboard

| API | الحالة |
|---|---|
| `POST /auth/register/employer`, `POST /auth/login`, `GET /auth/me` | ✅ |
| `GET/PUT /company`, `GET/PUT /employer/profile` | ✅/🟡 |
| `POST /jobs`, `GET /jobs/my`, `PUT /jobs/{id}`, `POST /jobs/{id}/skills`, `POST /jobs/{id}/publish`, `POST /jobs/{id}/close` | ✅/🟡/⚠️ |
| `GET /jobs/{id}/applications`, `GET /applications/{id}`, `POST /applications/{id}/status` | ✅/🟡 |
| `GET /jobs/{id}/candidates/ranked` | 🟡 |
| `GET/POST/PUT/DELETE /tests` | ✅/🟡 |
| `POST /applications/{id}/assign-test`, `GET /applications/{id}/tests`, `POST /tests/{attempt}/evaluate` | ✅/🟡 |
| `POST/GET /applications/{id}/interviews`, `PUT/DELETE /interviews/{id}`, `POST /interviews/{id}/complete`, `POST /interviews/{id}/evaluate` | ✅/🟡 |

### Admin Dashboard

| API | الحالة |
|---|---|
| `GET /admin/users`, `GET /admin/users/{id}`, `PATCH /admin/users/{id}/role`, `PATCH /admin/users/{id}/status` | ✅ |
| `GET /admin/companies`, `PATCH /admin/companies/{id}/approve`, `PATCH /admin/companies/{id}/reject` | ✅/🟡 |
| `GET/POST/PUT/DELETE /admin/skills` | ✅/🟡 |
| `GET/POST/PUT/DELETE /admin/tests` | ✅/🟡 |
| `GET /admin/reports/overview` | ⬜ |
| `GET /admin/audit-logs` | ⬜ |

---

## 19. أهم قرارات التوحيد قبل أن يبدأ الفرونت

| القرار | الخيار المقترح |
|---|---|
| Job status المنشورة | إما توحيد الكود على `published` أو توثيق أن `open` تعني Published. أنصح باعتماد `published` في الـ API النهائي أو تحويلها في Resource. |
| Apply API body | أضف `selected_cv_id`, `consent`, `cover_letter`, `screening_answers[]` حتى يكون التقديم واقعي. |
| CV Confirm | حالياً confirm كامل. الأفضل إضافة review decisions تدريجياً، أو توثيق أن MVP يقبل confirm كامل فقط. |
| Skills pivot | إذا أردنا scoring أفضل أضف `level`, `years_used` في `job_seeker_skills`. |
| Interview time | إما `scheduled_at + duration_minutes` أو `start_time + end_time`. للفرونت الأسهل `start_time + end_time`. |
| Application status actions | يمكن ترك endpoint عام `/status`، لكن للفرونت أوضح إضافة endpoints للأحداث المركبة: request-info, final-decision. |
| Audit | يجب تنفيذه قبل التسليم النهائي حتى لو بسيط. |

---

## 20. خلاصة تنفيذية

الريبو الحالي يغطي جزءاً كبيراً من Backend APIs الأساسية: Auth، Profile، Company، CV Upload/Parsing بشكل أساسي، Job Posting، Applications Workflow، Tests، Interviews، Matching، Notifications، وAdmin APIs.  
لكن قبل اعتماد العقد النهائي مع فريق الفرونت، توجد فجوات مهمة يجب إغلاقها أو توثيقها بوضوح: Password reset، Smart Profile Sync، Apply fields، Need More Information flow، Internal Notes، Audit Logs، Admin Reports، وبعض توحيد الـ enums والحقول.

