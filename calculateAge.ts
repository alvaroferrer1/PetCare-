export function calculateBiologicalAge(species: string, weightKg: number, birthDate: string | null) {
  if (!birthDate) return null;
  const birth = new Date(birthDate);
  const now = new Date();
  const diffTime = Math.abs(now.getTime() - birth.getTime());
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  const ageInYears = diffDays / 365.25;

  let humanAge = 0;
  if (ageInYears <= 0) return 0;
  if (ageInYears <= 1) {
    humanAge = ageInYears * 15;
  } else if (ageInYears <= 2) {
    humanAge = 15 + ((ageInYears - 1) * 9);
  } else {
    // Adult formula
    if (species === 'cat') {
      humanAge = 24 + ((ageInYears - 2) * 4);
    } else {
      // Dog depends on weight
      if (weightKg <= 9) {
        humanAge = 24 + ((ageInYears - 2) * 4); // Small
      } else if (weightKg <= 22) {
        humanAge = 24 + ((ageInYears - 2) * 5); // Medium
      } else if (weightKg <= 40) {
        humanAge = 24 + ((ageInYears - 2) * 6); // Large
      } else {
        humanAge = 24 + ((ageInYears - 2) * 7); // Giant
      }
    }
  }
  return Math.round(humanAge);
}
