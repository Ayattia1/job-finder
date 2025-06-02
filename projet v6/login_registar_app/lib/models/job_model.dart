class Job {
  final String id;
  final String jobTitle;
  final String? categoryName;
  final String jobLocation;
  final String salary;
  final String employerType;
  final String jobType;
  final String? logoUrl;
  final String? description;
  final String? companyName;
  final String? companyDescription;
  final String? companyWebsite;
  final String? contactEmail;
  final String? applicationDeadline;
  final String? firstNameEmployer;
  final String? lastNameEmployer;
  final String? idEmployer;
  final String? jobLocationType;



Job({
  required this.id,
  required this.jobTitle,
  this.categoryName,
  required this.jobLocation,
  required this.salary,
  required this.employerType,
  this.logoUrl,
  required this.jobType,
  required this.description,
  this.companyName,
  this.companyDescription,
  this.companyWebsite,
  this.contactEmail,
  this.applicationDeadline,
  this.firstNameEmployer,
  this.lastNameEmployer,
  required this.idEmployer,
  this.jobLocationType,
});

factory Job.fromJson(Map<String, dynamic> json) {
  return Job(
    id: json['id']?.toString() ?? '',
    jobTitle: json['job_title'] ?? '',
    categoryName: json['category']?['name'],
    jobLocation: json['job_location'] ?? '',
    salary: json['salary'] ?? '',
    employerType: json['employer_type'] ?? '',
    jobType: json['job_type'] ?? '',
    description: json['job_description'] ?? '',
    companyName: json['company_name'],
    companyDescription: json['company_description'],
    companyWebsite: json['company_website'],
    contactEmail: json['contact_email'],
    applicationDeadline: json['application_deadline'],
    firstNameEmployer: json['user']?['first_name'],
    lastNameEmployer: json['user']?['last_name'],
    idEmployer:json['user']?['id']?.toString() ?? '',
    jobLocationType: json['job_location_type'],
  );
}


Map<String, dynamic> toJson() {
  return {
    'id': id,
    'job_title': jobTitle,
    'category': {'name': categoryName},
    'job_location': jobLocation,
    'salary': salary,
    'employer_type': employerType,
    'job_type': jobType,
    'job_description' : description,
    'company_name': companyName,
    'company_description' : companyDescription,
    'company_website' : companyWebsite,
    'contact_email': contactEmail,
    'application_deadline': applicationDeadline,
    'user':{'first_name':firstNameEmployer,'last_name':lastNameEmployer,'id':idEmployer},
    'job_location_type':jobLocationType,
  };
}


}
